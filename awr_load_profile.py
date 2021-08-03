#!/logiciel/ms/ref/local/python/bin/python3

from functions import *

import tempfile
import cx_Oracle
import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.ticker as ticker
import matplotlib.font_manager as font_manager
import numpy as np
from matplotlib import style
import argparse
from tabulate import tabulate
import matplotlib.dates as mdates

import os

def make_patch_spines_invisible(ax):
    ax.set_frame_on(True)
    ax.patch.set_visible(False)
    for sp in ax.spines.values():
        sp.set_visible(False)

def main(args):

    start = args.start
    end = args.end
    ofile = args.ofile
    target = args.target

    tracePath = 'load_profile.trc'
    trace = open(tracePath,'w')

    conn = getCon(target)

    font = font_manager.FontProperties(family='DejaVu Sans Mono', style='normal', size=8)

    directory=os.environ.get('AWR_MINER_HOME') + "/csv/" +target
    if not os.path.exists(directory):
        os.makedirs(directory)

    # snapshots
    sqlfile = os.environ.get('AWR_MINER_HOME') + "/sql/" + "awr_snapshots.sql"
    with open(sqlfile, 'r') as file:
            sql = file.read()
    sql2exec=sql.replace('__START_DATE__', start).replace('__END_DATE__', end)

    trace.write(sql2exec)
    df_snapshots = pd.read_sql(sql2exec, con=conn)
    df_snapshots['STAT_NAME'] = 'elapsed'
    df_snapshots.rename(columns={'ELA': 'VALUE'}, inplace=True)

    trace.write("\n df_snapshots  \n")
    trace.write("\n"+str(list(df_snapshots.columns))+"\n")
    trace.write(tabulate( df_snapshots, headers='keys', tablefmt='psql'))
    # transacions
    metrics="user commits"
    sqlfile = os.environ.get('AWR_MINER_HOME') + "/sql/" + "sysstat2.sql"
    with open(sqlfile, 'r') as file:
            sql = file.read()
    sql2exec=sql.replace('__METRICS_NAME__', metrics).replace('__START_DATE__', start).replace('__END_DATE__', end)

    trace.write(sql2exec)

    outfile = os.environ.get('AWR_MINER_HOME') + "/png/" + target + "/" + ofile  + ".png"
    jsonfile = os.environ.get('AWR_MINER_HOME') + "/json/" + target + "/" + ofile + ".json"
    xcelfile = os.environ.get('AWR_MINER_HOME') + "/xlsx/" + target + "/" + ofile + ".xlsx"
    csvfile = os.environ.get('AWR_MINER_HOME') + "/csv/" + target + "/" + ofile + ".csv"

    df_commits = pd.read_sql(sql2exec, con=conn)
    if args.verbose:
        print(df_commits.head())

    #df_commits = df_commits.drop(columns=["SNAP_TIME"])
    trace.write("\n df_commits  \n")
    trace.write("\n"+str(list(df_commits.columns))+"\n")
    trace.write(tabulate( df_commits, headers='keys', tablefmt='psql'))

    #
    # sysstat 
    sqlfile = os.environ.get('AWR_MINER_HOME') + "/sql/" + "sysstat_load_profile.sql"
    with open(sqlfile, 'r') as file:
            sql = file.read()
    sql2exec=sql.replace('__START_DATE__', start).replace('__END_DATE__', end)
    df_sysstat = pd.read_sql(sql2exec, con=conn)

    trace.write("\n df_sysstat  \n")
    trace.write("\n"+str(list(df_sysstat.columns))+"\n")
    trace.write(tabulate( df_sysstat, headers='keys', tablefmt='psql'))

    # merge
    merged = pd.concat([df_sysstat, df_commits, df_snapshots], ignore_index=True, sort=False)
    trace.write("\n merged  \n")
    trace.write("\n"+str(list(merged.columns))+"\n")
    trace.write(tabulate( merged, headers='keys', tablefmt='psql'))

    merged = merged.drop(columns=["SNAP_ID"])
    results = merged.pivot_table(index='SNAP_TIME', columns='STAT_NAME', values='VALUE', fill_value=0 )

    if args.verbose:
        print(results.head())

    print(args.json)
    print(type(args.json))
    if args.json:
        results.to_json(jsonfile)
        print("file " + jsonfile + " created")
        return
    if args.xlsx:
        results.to_json(xcelfile)
        print("file " + xcelfile + " created")
        return
    if args.csv:
        results.to_csv(csvfile)
        print("file " + csvfile + " created")
        return

#results = merged.pipe(multiIndex_pivot, index = ['SNAP_ID', 'SNAP_TIME'], columns = ['STAT_NAME'], values = 'VALUE')

#trace.write("\n results  \n")
#trace.write("\n"+str(list(results.columns))+"\n")
#trace.write(tabulate( results, headers='keys', tablefmt='psql'))

#results.reset_index(inplace=True)
#metrics = results[['SNAP_TIME','db block changes','physical read total bytes','physical write total bytes']]
#metrics.index = pd.to_datetime(metrics["SNAP_TIME"], format="%Y%m%d%H%M%S")

#trace.write("\n metrics  \n")
#trace.write("\n"+str(list(metrics.columns))+"\n")
#trace.write(tabulate( metrics, headers='keys', tablefmt='psql'))

#return

#df.plot(kind='area', stacked=False)
# create figure and axis objects with subplots()
#mkfunc = lambda x, pos: '%1.1fG' % (x * 1e-9) if x >= 1e9 else '%1.1fM' % (x * 1e-6) if x >= 1e6 else '%1.1fK' % (x * 1e-3) if x >= 1e3 else '%1.1f' % x
#mkformatter = ticker.FuncFormatter(mkfunc)

#fig,ax = plt.subplots()
#ax.plot(metrics['SNAP_TIME'], metrics['db block changes'], color="red")
#ax.set_ylabel("db block changes",color="red",fontsize=8)
#ax.yaxis.set_major_formatter(mkformatter)

#ax2=ax.twinx()
#ax2.plot(metrics['SNAP_TIME'], metrics['physical read total bytes'], color="blue")
#ax2.set_ylabel("physical read total bytes",color="blue",fontsize=8)
#ax2.yaxis.set_major_formatter(mkformatter)

#ax3=ax.twinx()
#ax3.plot(metrics['SNAP_TIME'], metrics['physical write total bytes'], color="green")
#ax3.set_ylabel("physical write total bytes",color="green",fontsize=8)
#ax3.yaxis.set_major_formatter(mkformatter)
#ax3.spines["right"].set_position(("axes", 1.2))
#make_patch_spines_invisible(ax3)

#hours = mdates.HourLocator()    # every year
#minutes = mdates.MinuteLocator()  # every month
#hoursFmt = mdates.DateFormatter('\n%H')
#miFmt = mdates.DateFormatter('%M')

#ax.xaxis.set_major_locator(hours)
#ax.xaxis.set_minor_locator(minutes)
#ax.xaxis.set_major_formatter(hoursFmt)
#ax.xaxis.set_minor_formatter(miFmt)

# format
#ax.xaxis.grid(False)
#ax2.yaxis.grid(False)
#ax3.yaxis.grid(False)
#ax.yaxis.set_major_formatter(plt.FuncFormatter(lambda x, loc: "{:,}".format(int(x))))

#for label in ax.xaxis.get_minorticklabels()[::2]: # show every other minor label
#    label.set_visible(False)

# turn off x-axis
#x_axis = ax.axes.get_xaxis()
#x_label = x_axis.get_label()
#x_label.set_visible(False)

# turn-off left y-axis
#ax.yaxis.set_visible(False)

# adjust fontsize
#plt.tick_params(axis='both', which='major', labelsize=16)

#plt.title(metrics)
#plt.xticks(rotation=45)
#plt.gca().legend(prop=font, loc=9, bbox_to_anchor=(0.5, -0.1),title=metrics, fancybox=True)
#plt.ylabel(metrics,color="red")

# format x-axis ticks as dates

# format
#ax.xaxis.grid(False)
#ax.yaxis.set_major_formatter(plt.FuncFormatter(lambda x, loc: "{:,}".format(int(x))))

#years = mdates.YearLocator()    # every year
#months = mdates.MonthLocator()  # every month
#yearsFmt = mdates.DateFormatter('\n%Y')
#moFmt = mdates.DateFormatter('%m') # (%b for Jan, Feb Mar; %m for 01 02 03)
#ax.xaxis.set_major_locator(years)
#ax.xaxis.set_minor_locator(months)
#ax.xaxis.set_major_formatter(yearsFmt)
#ax.xaxis.set_minor_formatter(moFmt)
#for label in ax.xaxis.get_minorticklabels()[::2]: # show every other minor label
#label.set_visible(False)

# turn off x-axis
#x_axis = ax.axes.get_xaxis()
#x_label = x_axis.get_label()
#x_label.set_visible(False)

#plt.savefig(outfile, format='png', bbox_inches='tight', dpi=300 )

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument("--start", required=True )
    parser.add_argument("--end", required=True )
    parser.add_argument("--ofile", required=True )
    parser.add_argument("--target", required=True )
    parser.add_argument("--verbose", action='store_true', help="switch verbose mode on")
    parser.add_argument("--json", action='store_true', help="store dataframe to disk")
    parser.add_argument("--xlsx", action='store_true', help="store dataframe to disk")
    parser.add_argument("--csv", action='store_true', help="store dataframe to disk")
    #args = vars(parser.parse_args())
    args =parser.parse_args()
    main(args)
