#!/logiciel/ms/ref/local/python/bin/python3
import pandas as pd
import matplotlib.ticker as ticker
import matplotlib.pyplot as plt
import matplotlib.dates as mdates
import os
import argparse

def getYAxisFormatter():
    mkfunc = lambda x, pos: '%1.1fG' % (x * 1e-9) if x >= 1e9 else '%1.1fM' % (x * 1e-6) if x >= 1e6 else '%1.1fK' % (x * 1e-3) if x >= 1e3 else '%1.1f' % x
    mkformatter = ticker.FuncFormatter(mkfunc)
    return mkformatter

def setYAxisShift(ax,pos):
    ax.spines["right"].set_position(("axes", pos))

def setYLabelSize(ax,size):
    ax.tick_params(axis='y',labelsize=size) 

def plot(df, m1,title,target,ofile):

    outfile = os.environ.get('AWR_MINER_HOME') + '/png/' + target + "/" +  ofile + ".png"

    df['SNAP_TIME']=pd.to_datetime(df['SNAP_TIME'].astype(str), format='%Y%m%d%H%M')
    df = df.set_index('SNAP_TIME')

    fig, ax = plt.subplots()

    fig.subplots_adjust(right=0.75)

    col=m1
    p1, = ax.plot(df.index,df[[col]],label=col,c='#0000FF')

    ax.yaxis.label.set_color(p1.get_color())
    ax.yaxis.label.set_size(12)
    setYLabelSize(ax,12)

    ax.set_ylabel(m1)

    mkformatter = getYAxisFormatter()
    ax.yaxis.set_major_formatter(mkformatter)

    plt.title(title, fontsize=16, x=.65, y=1.05)

    locator = mdates.AutoDateLocator(minticks = 3, maxticks = 8)
    formatter = mdates.ConciseDateFormatter(locator)

    ax.xaxis.set_major_locator(locator)
    ax.xaxis.set_major_formatter(formatter)

    plt.savefig(outfile, format='png', bbox_inches='tight', dpi=600 )

def main(args):
    
    ifile=args.ifile
    m1=args.m1
    ofile=args.ofile
    target=args.target
    df = pd.read_csv(ifile, header='infer' )
    plot(df, m1, title=m1 +' for ' + target,target=target,ofile=ofile)

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Query AWR')
    parser.add_argument('--ifile', required=True)
    parser.add_argument('--m1', required=True)
    parser.add_argument('--target', required=True)
    parser.add_argument('--ofile', required=True)
    args = parser.parse_args()
    main(args)
