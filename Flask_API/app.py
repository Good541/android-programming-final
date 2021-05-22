from flask import Flask

UPLOAD_FOLDER = 'D:/Project/git/finalproj/Upload'

app = Flask(__name__)
app.secret_key = 'you-will-never-guess'
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER
app.config['MAX_CONTENT_LENGTH'] = 16 * 1024 * 1024