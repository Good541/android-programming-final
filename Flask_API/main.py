from flask import Flask , render_template, jsonify, send_file, send_from_directory
from flask import request, redirect, url_for
from flask_apscheduler import APScheduler
from flask_login import LoginManager, UserMixin, login_user, login_required, logout_user, current_user
from flask_sqlalchemy import SQLAlchemy
from flask_cors import CORS
from flask_swagger_ui import get_swaggerui_blueprint
from apscheduler.schedulers.blocking import BlockingScheduler
from apscheduler.schedulers.background import BackgroundScheduler
from flask_bootstrap import Bootstrap
from flask_wtf import FlaskForm 
from wtforms import StringField, PasswordField, BooleanField
from wtforms.validators import InputRequired, Email, Length, NoneOf
from werkzeug.security import generate_password_hash, check_password_hash
import datetime
from app import app
from managedb import Managedb
import json
import pandas as pd
import io

from werkzeug.utils import secure_filename
import os
app = Flask(__name__)
app.config['SECRET_KEY'] = 'you-will-never-guess'
app.config['SQLALCHEMY_DATABASE_URI'] = 'mysql+pymysql://root:75429@127.0.0.1:3306/android'

ALLOWED_EXTENSIONS = set(['csv', 'xlsx', 'xls'])
FORBIDDEN_STRING = ["\"", "\\",  "/", ":", "?", "*", "<", ">", "|", " "]
USER_AVATAR_PATH = "D:/android programming/proj/Flask_API/Userdata/"


def allowed_file(filename):
	return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS


bootstrap = Bootstrap(app)
db = SQLAlchemy(app)
login_manager = LoginManager()
login_manager.init_app(app)
login_manager.login_view = 'login'

class Userdata(UserMixin, db.Model):
    uid = db.Column(db.Integer, primary_key=True)
    uname = db.Column(db.String(45), unique=True)
    pwd = db.Column(db.String(200), unique=True)

    def get_id(self):
        return (self.uid)

@login_manager.user_loader
def load_user(user_id):
    return Userdata.query.get(int(user_id))

class LoginForm(FlaskForm):
    username = StringField('username', validators=[InputRequired(), Length(min=4, max=15)])
    password = PasswordField('password', validators=[InputRequired(), Length(min=5, max=80)])
    remember = BooleanField('remember me')

class RegisterForm(FlaskForm):
    email = StringField('email', validators=[InputRequired(), Email(message='Invalid email'), Length(max=50)])
    username = StringField('username', validators=[InputRequired(), Length(min=4, max=15)])
    password = PasswordField('password', validators=[InputRequired(), Length(min=8, max=80)])

class EditUserForm(FlaskForm):
    username = StringField('username', validators=[InputRequired(), Length(min=4, max=15)])
    password = PasswordField('password', validators=[InputRequired(), Length(min=5, max=80)])
    remember = BooleanField('remember me')

@app.route('/loginstatus', methods=['GET'])
def loginstatus():
    if current_user.is_authenticated:
        return "Authorized"
    else:
        return "Unauthorized"

@app.route('/login', methods=['POST'])
def login():
    if current_user.is_authenticated:
        return "Authorized"
    form = LoginForm()

    content = request.get_json(silent=True)
    remember = BooleanField(content['rememberme'])
    print(content)
    for x in FORBIDDEN_STRING:
        if content['uname'].find(x) > -1:
            warning = 'username must not contain spacebar and any of the follow characters: \", \\, /, :, ?, *, <, >, |'
            return warning
    user = Userdata.query.filter_by(uname=content['uname']).first()
    if user:
        if check_password_hash(user.pwd, content['pwd']):
            login_user(user,  remember=form.remember.data)
            print("Successful")
            return "Successful"
    warning = 'username or password is incorrect'
    print(warning)
    return warning

@app.route('/signup', methods=['POST'])
def signup():
    form = RegisterForm()
    content = request.get_json(silent=True)
    for x in FORBIDDEN_STRING:
        if content['uname'].find(x) > -1:
            warning = 'username must not contain spacebar and any of the follow characters: \", \\, /, :, ?, *, <, >, |'
            return warning
    hashed_password = generate_password_hash(content['pwd'], method='sha256')
    readuser = Managedb()
    userlist = readuser.readuserlist()
    count = 0
    _isuidGenerate = False
    for x in userlist:
        if x[1] == content['uname']:
            return "Username already taken"
    for x in userlist:
        if x[0] != count:
            newuseruid = count
            _isuidGenerate = True
            break
        count+=1
    if _isuidGenerate == False:
        newuseruid = count
    new_user = Userdata(uid=newuseruid, uname=content['uname'], pwd=hashed_password)
    db.session.add(new_user)
    db.session.commit()

    return 'New user has been created!'

@app.route('/changepassword', methods=['POST'])
@login_required
def changepassword():
    content = request.get_json(silent=True)
    print(content)
    if check_password_hash(current_user.pwd, content['oldpwd']):
        hashed_password = generate_password_hash(content['newpwd'], method='sha256')
        changepwd = Managedb()
        changepwd.updateuserpassword(current_user.uid, hashed_password)
        return "Change password successful"
    warning = 'Old password is incorrect'
    print(warning)
    return warning

@app.route('/logout')
@login_required
def logout():
    logout_user()
    return "Successful"

@app.route('/userdata', methods = ['GET'])
@login_required
def userdata():
    return jsonify({'uid':current_user.uid, 'uname':current_user.uname})

@app.route('/getuseravatar', methods = ['GET'])
@login_required
def getuseravatar():
    return send_file(
    USER_AVATAR_PATH+current_user.uname+".jpg",
    as_attachment=True,
    attachment_filename='test.jpg',
    mimetype='image/jpeg'
 )
    # send_file(USER_AVATAR_PATH+current_user.uname+".jpg", mimetype='image/jpg')

@app.route('/updateanimelist', methods = ['POST'])
@login_required
def updateanimelist():
    content = request.get_json(silent=True)
    print(content)
    updateanimelist = Managedb()
    updateanimelist.updatedb(content, current_user.uid)
    

    return "Update Successful"

@app.route('/deleteanimelist', methods = ['POST'])
@login_required
def deleteanimelist():
    # if request.method == 'POST':
    content = request.get_json(silent=True)
    print(content)
    updateanimelist = Managedb()
    updateanimelist.deletedb(content, current_user.uid)

    return "Update Successful"

@app.route('/getanimelist', methods = ['GET'])
@login_required
def getanimelist():
    # if request.method == 'POST':
    getnaimelist = Managedb()
    print(getnaimelist.readdb(current_user.uid))
    
    df = pd.DataFrame(getnaimelist.readdb(current_user.uid), columns=['listid','uid','anilistid','malid','status','episode','rating','romaji', 'imgurl', 'totaleps'])
    df = df.sort_values(by=['romaji'], ascending=True)
    json = df.to_dict('records')
    print(type(json))

    
    return jsonify(json)

@app.route('/addanime', methods = ['POST'])
@login_required
def addanime():

    content = request.get_json(silent=True)
    
    addtodb = Managedb()
    addtodb.writedb(content, current_user.uid)


    return "Update Successful"

@app.route('/getlclist', methods = ['GET'])
def getlclist():
    # if request.method == 'POST':
    getnaimelist = Managedb()
    
    df = pd.DataFrame(getnaimelist.readlclist(), 
    columns = ['animelicenseid','anilistid','romaji',
    'season','year','format', 'imgurl','licensor','musethyt',
     'bilibili', 'aisplay','netflix','anioneyt',
     'iqiyi','flixer','wetv','trueid', 'viu','pops', 'linetv',
      'amazon', 'iflix'])
    df = df.sort_values(by=['year'], ascending=True)
    json = df.to_dict('records')
    print(type(json))

    return jsonify(json)

@app.route('/filterlclist', methods = ['GET'])
def filterlclist():
    # if request.method == 'POST':
    getnaimelist = Managedb()
    content = request.get_json(silent=True)
    content = {'season': 'Winter'}
    df = pd.DataFrame(getnaimelist.readlclist(), 
    columns = ['animelicenseid','anilistid','romaji',
    'season','year','format', 'imgurl','licensor','musethyt',
     'bilibili', 'aisplay','netflix','anioneyt',
     'iqiyi','flixer','wetv','trueid', 'viu','pops', 'linetv',
      'amazon', 'iflix'])
    df1 = df.loc[(df[list(content)] == pd.Series(content)).all(axis=1)]
    df = df.sort_values(by=['year'], ascending=True)
    json = df1.to_dict('records')
    print(type(json))

    return jsonify(json)
if __name__ == '__main__':
    app.debug = True
    app.run(host='0.0.0.0',port=8000)
