def fill_in_missing_dates(df, date_col_name = 'date',date_order = 'asc', fill_value = 0, days_back = 30):

    df.set_index(date_col_name,drop=True,inplace=True)
    df.index = pd.DatetimeIndex(df.index)
    d = datetime.now().date()
    d2 = d - timedelta(days = days_back)
    idx = pd.date_range(d2, d, freq = "D")
    df = df.reindex(idx,fill_value=fill_value)
    df[date_col_name] = pd.DatetimeIndex(df.index)

    return df
