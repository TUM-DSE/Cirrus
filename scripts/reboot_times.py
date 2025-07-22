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

def setup_parser():
    parser = argparse.ArgumentParser(
        description='Plot graph'
    )

    parser.add_argument('-t',
                        '--title',
                        type=str,
                        help='Title of the plot',
                        )
    parser.add_argument('-i',
                        '--input_dir',
                        type=str,
                        help='Input dir',
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
    plt.xlabel('System')
    plt.ylabel('Time (ms)')
    plt.grid()

    plots = []

    dfs = []
    df = pd.read_csv(args.input_dir+'reconf.csv')

    plot = sns.barplot(
        data=df,
        x = "system",
        y = "time",
        width = 0.5,
        gap = -0.5
        # hue = "system",
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
    ax.bar_label(ax.containers[0], fontsize=8);

    legend = None

    """
    sns.move_legend(ax, "lower left",
                    # bbox_to_anchor=(0.5, 0.95),
                    bbox_to_anchor=(-0.011, -0.1),
                    ncol=1, title=None, frameon=False)
    """
    # plot.add_legend(
    #         bbox_to_anchor=(0.55, 0.3),
    #         loc='upper left',
    #         ncol=3, title=None, frameon=False,
    #                 )

    # if args.compress:
    #     # empty  name1 name2 ...
    #     # 25pctl x     x     ...
    #     # 50pctl x     x     ...
    #     # 75pctl x     x     ...
    #     # 99pctl x     x     ...
    #     dummy, = plt.plot([0], marker='None', linestyle='None',
    #                      label='dummy')
    #     legend = plt.legend(
    #         chain([
    #             [dummy, p._plot25, p._plot50, p._plot75, p._plot99]
    #             for p in plots
    #         ]),
    #         chain([
    #             [p._name, '25.pctl', '50.pctl', '75.pctl', '99.pctl']
    #             for p in plots
    #         ]),
    #         ncol=len(plots),
    #         prop={'size': 8},
    #         loc="lower right",
    #     )
    # else:
    #     legend = plt.legend(loc="lower right", bbox_to_anchor=(1.15, 1),
    #                         ncol=3, title=None, frameon=False,
    #                         )
    plt.ylim(0, 6)
    ax.annotate(
        "↓ Lower is better", # or ↓ ← ↑ →
        xycoords="axes points",
        # xy=(0, 0),
        xy=(10, 0),
        xytext=(-25, -40),
        fontsize=8,
        color="navy",
        weight="bold",
    )
    ax.set(xlabel=None)

    # legend.get_frame().set_facecolor('white')
    # legend.get_frame().set_alpha(0.8)
    fig.tight_layout(pad=0.2)
    plt.subplots_adjust(left=0.25)
    plt.xticks(rotation=30)
    plt.savefig(args.file)
    plt.close()


if __name__ == '__main__':
    main()

