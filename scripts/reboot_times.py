#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import matplotlib as mpl  # type: ignore
import matplotlib.pyplot as plt  # type: ignore
import seaborn as sns  # type: ignore
from typing import Any, Dict, List, Union
import pandas as pd
import os
import numpy as np

dir_path = os.path.dirname(os.path.realpath(__file__))
result_dir = os.path.join(dir_path, "results")
# common graph settings

mpl.use("Agg")
mpl.rcParams["text.latex.preamble"] = r"\usepackage{amsmath}"
mpl.rcParams["pdf.fonttype"] = 42
mpl.rcParams["ps.fonttype"] = 42
mpl.rcParams["font.family"] = "libertine"

sns.set_style("whitegrid")
sns.set_style("ticks", {"xtick.major.size": 8, "ytick.major.size": 8})
sns.set_context("paper", rc={"font.size": 5, "axes.titlesize": 5, "axes.labelsize": 8})

# 3.3 inch for single column, 7 inch for double column
figwidth_third = 2
figwidth_half = 3.3
figwidth_full = 7

FONTSIZE = 8

palette = sns.color_palette("pastel")
hatches = ["", "//", "x"]


def load_data() -> pd.DataFrame:
    df = pd.read_csv(os.path.join(result_dir, 'reconf.csv'))
    return df


def main():
    data = load_data()
    #print(data)

    # create bar plot
    fig, ax = plt.subplots(figsize=(figwidth_third, 1.5))
    data.plot(kind="bar", ax=ax, color=palette, edgecolor="black", fontsize=FONTSIZE)
    # annotate values
    for container in ax.containers:
        ax.bar_label(container, fontsize=FONTSIZE)
    # set hatch
    bars = ax.patches
    hs = []
    for h in hatches:
        for i in range(int(len(bars) / len(hatches))):
            hs.append(h)
    for bar, hatch in zip(bars, hs):
        bar.set_hatch(hatch)
    ax.set_ylabel("Time (ms)")
    ax.set_xlabel("")
    ax.set_xticklabels(data.system, rotation=0)
    # ax.legend(loc="upper left", title=None, fontsize=FONTSIZE,
    #           bbox_to_anchor=(-0.02, 1.0))
    # place legend below the graph
    #ax.legend(
    #    loc="right",
    #    title=None,
    #    fontsize=FONTSIZE,
    #    bbox_to_anchor=(0.5, -0.15),
    #    ncol=2,
    #)
    ax.get_legend().remove()
    ax.set_title("Lower is better ↓", fontsize=FONTSIZE, color="navy")
    # sns.despine()
    plt.tight_layout()
    plt.savefig(os.path.join(result_dir, "reboot_times.pdf"), format="pdf", pad_inches=0, bbox_inches="tight")


if __name__ == "__main__":
    main()
