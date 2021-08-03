#!/logiciel/ms/ref/local/python/bin/python3
import pandas as pd


# --------------------------------------------------------------------------------------------------------
def plot(df, title):

    import matplotlib.pyplot as plt

    #plt.style.use('mag')
    fig, ax = plt.subplots()
    fig.subplots_adjust(right=0.75)

    mm = ax.twinx()
    yy = ax.twinx()
    for col in df.columns:
        mm.plot(df.index,df[[col]],label=col)
    yy.spines["right"].set_position(("axes", 1.2))
    mm.set_ylabel('Monthly Hours')
    yy.set_ylabel('Yearly Hours')
    yy.set_ylim(mm.get_ylim()[0]*12, mm.get_ylim()[1]*12)
    
    mm.tick_params(axis='y',labelsize=16) # set monthly labelsize (not global)

    # format
    ax.xaxis.grid(False)
    mm.yaxis.grid(False)
    yy.yaxis.grid(False)
    ax.yaxis.set_major_formatter(plt.FuncFormatter(lambda x, loc: "{:,}".format(int(x))))
    plt.title(title, fontsize=16, x=.65, y=1.05)

    # format x-axis ticks as dates
    import matplotlib.dates as mdates
    years = mdates.YearLocator()    # every year
    months = mdates.MonthLocator()  # every month
    yearsFmt = mdates.DateFormatter('\n%Y')
    moFmt = mdates.DateFormatter('%m') # (%b for Jan, Feb Mar; %m for 01 02 03)
    ax.xaxis.set_major_locator(years)
    ax.xaxis.set_minor_locator(months)
    ax.xaxis.set_major_formatter(yearsFmt)
    ax.xaxis.set_minor_formatter(moFmt)
    for label in ax.xaxis.get_minorticklabels()[::2]: # show every other minor label
        label.set_visible(False)
    
    # turn off x-axis
    x_axis = ax.axes.get_xaxis()
    x_label = x_axis.get_label()
    x_label.set_visible(False)

    # turn-off left y-axis
    ax.yaxis.set_visible(False)

    # adjust fontsize
    plt.tick_params(axis='both', which='major', labelsize=16)

    handles, labels = mm.get_legend_handles_labels()
    mm.legend(fontsize=14, loc=6)

    plt.savefig('matplotlib-twin-axes.png', bbox_inches='tight', dpi=150)


def main():

    df = pd.read_excel('data.xlsx').set_index('Date')
    plot(df, title='Multi Y-Axis Scales')


if __name__ == '__main__':
    main()
