#!/usr/bin/env python3

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.colors as mcolors
import seaborn as sns
import argparse
from re import search
from os.path import basename, getsize
import pandas as pd


# Set global font size
plt.rcParams['font.size'] = 8  # Sets the global font size to 14
# plt.rcParams['axes.labelsize'] = 10  # Sets axis label size
# plt.rcParams['xtick.labelsize'] = 8  # Sets x-tick label size
# plt.rcParams['ytick.labelsize'] = 8  # Sets y-tick label size
# plt.rcParams['legend.fontsize'] = 8  # Sets legend font size
# plt.rcParams['axes.titlesize'] = 16  # Sets title font size
plt.rcParams["legend.borderaxespad"]=0.01

def setup_parser():
    parser = argparse.ArgumentParser(
        description='Plot graph'
    )

    parser.add_argument('-t',
                        '--title',
                        type=str,
                        help='Title of the plot',
                        )
    parser.add_argument('-f',
                        '--file',
                        type=str,
                        help='Output file',
                        )
    parser.add_argument('-W', '--width',
                        type=float,
                        default=12,
                        help='Width of the plot in inches'
                        )
    parser.add_argument('-H', '--height',
                        type=float,
                        default=6,
                        help='Height of the plot in inches'
                        )
    return parser


def parse_args(parser):
    args = parser.parse_args()
    return args


def mpps_to_gbitps(mpps, size):
    return mpps * (size + 20) * 8 / 1000 # 20: preamble + packet gap

def main():
    parser = setup_parser()
    args = parse_args(parser)

    fig = plt.figure(figsize=(args.width, args.height))
    ax = fig.add_subplot(1, 1, 1)
    ax.set_axisbelow(True)
    if args.title:
        plt.title(args.title)
    plt.ylabel('')
    plt.xlabel('Image size\n(MiB)')
    plt.grid()

    plots = []

    dfs = []
    df = pd.DataFrame()
    df['system'] = [ "Ubuntu", "Alpine", "Unikraft", "Cirrus" ]
    # sqlite : 1765712
    # Linux VM -> Alpine: 110675968, Ubuntu: 639152640
    df['size'] = [ 640918352, 112441680, 2238424, 4396224 ]
    df['sizeMB'] = df['size'].div(1048576).round(2) # 1 MiB

    plot = sns.barplot(
        data=df,
        y = "system",
        x = "sizeMB",
        #hue = "location",
        gap = 0.1,
        orient = "h"
        # style = "system",
        # label=f'{self._name}',
        # color=self._line_color,
        # linestyle=self._line,
        # linewidth=1,
        # markers=True,
        # errorbar='ci',
        # markers=[ 'X' ],
        # markeredgecolor='black',
        # markersize=60,
        # markeredgewidth=1,
    )
    ax.bar_label(ax.containers[0], fontsize=8, fmt='%s MiB', padding=1)
    #ax.bar_label(ax.containers[1], fontsize=8);
    plt.xlim(0, 2000)
    legend = None
    ax.spines['right'].set_visible(False)
    
    """
    sns.move_legend(ax, "lower center",
                    bbox_to_anchor=(0.2, 0.95),
                    ncol=2, title=None, frameon=False, columnspacing=0.5)
    """
    ax.annotate(
        "← Lower\nis better", # or ↓ ← ↑ →
        xycoords="axes points",
        # xy=(0, 0),
        xy=(10, 0),
        xytext=(-38, -30),
        fontsize=8,
        color="navy",
        weight="bold",
    )

    # legend.get_frame().set_facecolor('white')
    # legend.get_frame().set_alpha(0.8)
    fig.tight_layout(pad=0.2)
    plt.subplots_adjust(left=0.37)
    plt.savefig(args.file)
    plt.close()


if __name__ == '__main__':
    main()

