import mysql.connector
from sqlalchemy import create_engine
import pandas as pd

class Managedb():

  def readuserlist(self):
    def sortSecond(val):
      return val[0] 
    mydb = mysql.connector.connect(
      host="localhost",
      port = 3306,
      user="root",
      password="75429",
      database="android"
    )

    mycursor = mydb.cursor()
    mycursor.execute("SELECT * FROM userdata")
    myresult = mycursor.fetchall()
    # for x in myresult:
    #   print(x)
    # print(myresult)
    # print(type(myresult))
    # df = pd.DataFrame(myresult, columns=['uid','anilistid','malid','status','episode','rating','romaji'])
    myresult.sort(key = sortSecond) 
    return myresult

  def updateuserpassword(self, uid, newpassword):
    mydb = mysql.connector.connect(
          host="localhost",
          port = 3306,
          user="root",
          password="75429",
          database="android"
        )
    mycursor = mydb.cursor()
    sql = "UPDATE userdata SET pwd = %s WHERE uid = %s"
    record = (newpassword, uid)
    try:
      mycursor.execute(sql, record)
      mydb.commit()
      print("Successful")
    except:
      print("error")
        
  def readdb(self, uid):
    mydb = mysql.connector.connect(
      host="localhost",
      port = 3306,
      user="root",
      password="75429",
      database="android"
    )

    mycursor = mydb.cursor()
    record = (uid,)
    mycursor.execute("SELECT * FROM useranimelist where uid = %s", record)
    myresult = mycursor.fetchall()
    # for x in myresult:
    #   print(x)
    # print(myresult)
    # print(type(myresult))
    # df = pd.DataFrame(myresult, columns=['listid','uid','anilistid','malid','status','episode','rating','romaji'])

    return myresult

  def writedb(self, content, uid):
    # self.df['Receive_date'] = pd.to_datetime(self.df['Receive_date']).dt.strftime('%d/%m/%Y')
    listid = 1
    read = Managedb()
    useranimelist = read.readdb(uid)

    mydb = mysql.connector.connect(
          host="localhost",
          port = 3306,
          user="root",
          password="75429",
          database="android"
        )
    mycursor = mydb.cursor()
   
    for x in useranimelist:
      if content['anilistid'] == x[2]:
          status = "Already added"
          print(status)
          return status
    try:
        sql = "SELECT MAX(listid) FROM useranimelist WHERE uid = %s"
        record = (uid,)
        mycursor.execute(sql, record)
        myresult = mycursor.fetchall()
        print(myresult)
        for x in myresult:
            for y in x:
                listid += int(y)
    except:
        print("error")
    # finally:
        # print("error")
    writedata = {'listid': listid}
    writedata.update(content)
    df = pd.DataFrame([writedata])
    df.head()
    sqlEngine = create_engine('mysql+pymysql://root:75429@127.0.0.1:3306/android')
    # df2 = pd.read_sql_query("select * from dataset3",sqlEngine)
    # print(df2)
    # self.df['Receive_date'] = pd.to_datetime(self.df['Receive_date']).dt.strftime('%d/%m/%Y')
    # self.df['Treatment Date'] = pd.to_datetime(self.df['Treatment Date']).dt.strftime('%d/%m/%Y')
    # self.df['Discharge Date'] = pd.to_datetime(self.df['Discharge Date']).dt.strftime('%d/%m/%Y')
    
    df.to_sql('useranimelist', con=sqlEngine, if_exists='append', index=False)

  def updatedb(self, content, uid):
  # self.df['Receive_date'] = pd.to_datetime(self.df['Receive_date']).dt.strftime('%d/%m/%Y')
    # listid = 1
    # uid = 0
    read = Managedb()
    useranimelist = read.readdb(uid)

    mydb = mysql.connector.connect(
          host="localhost",
          port = 3306,
          user="root",
          password="75429",
          database="android"
        )
    mycursor = mydb.cursor()
    found = False
    for x in useranimelist:
      if content['anilistid'] == x[2]:
          status = "Found"
          found = True
          print(status)
          break
    if found == False:
      status = "Not found"
      print(status)
      return status        
    sql = "UPDATE useranimelist SET status = %s, episode = %s, rating = %s WHERE listid = %s and uid = %s"
    record = (content['status'], content['episode'], content['rating'], content['listid'], uid)

    try:
      mycursor.execute(sql, record)
      mydb.commit()
        
    except:
        print("error")

  def deletedb(self, content, uid):
  # self.df['Receive_date'] = pd.to_datetime(self.df['Receive_date']).dt.strftime('%d/%m/%Y')
    # listid = 1
    # uid = 0
    read = Managedb()
    useranimelist = read.readdb(uid)

    mydb = mysql.connector.connect(
          host="localhost",
          port = 3306,
          user="root",
          password="75429",
          database="android"
        )
    mycursor = mydb.cursor()
    found = False
    for x in useranimelist:
      if content['listid'] == x[0]:
          status = "Found"
          found = True
          print(status)
          break
    if found == False:
      status = "Not found"
      print(status)
      return status        
    sql = "DELETE FROM useranimelist WHERE listid = %s and uid = %s"
    record = (content['listid'], uid)
    mycursor.execute(sql, record)
    mydb.commit()

  def readlclist(self):
    mydb = mysql.connector.connect(
      host="localhost",
      port = 3306,
      user="root",
      password="75429",
      database="android"
    )

    mycursor = mydb.cursor()
    mycursor.execute("SELECT * FROM animelicenseinfo")
    myresult = mycursor.fetchall()
    # for x in myresult:
    #   print(x)
    # print(myresult)
    # print(type(myresult))
    # df = pd.DataFrame(myresult, columns=['listid','uid','anilistid','malid','status','episode','rating','romaji'])

    return myresult

  def readlcbyid(self, anilistid):
    mydb = mysql.connector.connect(
      host="localhost",
      port = 3306,
      user="root",
      password="75429",
      database="android"
    )

    mycursor = mydb.cursor()
    record = (anilistid,)
    mycursor.execute("SELECT * FROM animelicenseinfo where anilistid = %s", record)
    myresult = mycursor.fetchall()
    # for x in myresult:
    #   print(x)
    # print(myresult)
    # print(type(myresult))
    # df = pd.DataFrame(myresult, columns=['listid','uid','anilistid','malid','status','episode','rating','romaji'])

    return myresult