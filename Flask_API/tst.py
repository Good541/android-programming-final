from datetime import datetime
your_timestamp = 1621089000
date = datetime.fromtimestamp(your_timestamp)
print(date.year)
date_time_str = "15/05/2021 23:59:59"
date_time_obj = datetime.strptime(date_time_str, '%d/%m/%Y %H:%M:%S')
date_timestamp = int(datetime.timestamp(date_time_obj))
print(date_timestamp)