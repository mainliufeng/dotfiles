#!/usr/bin/env python
# -*- coding: utf-8 -*-

import fire
import csv
import pandas as pd


def fix(input, output, sep=',', output_sep=None):
    '''
    修复pandas度csv缺行的问题，
    先读入，在写到output

    input、output都没有header
    '''
    if output_sep is None:
        output_sep = sep
    df = pd.read_csv(input, sep=sep, header=None, quoting=csv.QUOTE_NONE)
    df.to_csv(output, sep=output_sep, index=False, header=False)


if __name__ == '__main__':
    fire.Fire(fix)
