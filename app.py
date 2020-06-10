# Flask for back-end page serving, render_template for 
# serving pages, request and jsonify for Decryptr dynamic loading
from flask import Flask, render_template, request, jsonify

# For Gzip flask responses
from flask_compress import Compress

# Dynamic path used to support importing from subdirectories
# across multiple platforms (tested between Windows and Linux)
import os, sys
sys.path.append(os.path.join(os.path.dirname(__file__), "static/decryptr/build"))

# Function to deal with Decryptr stuff all at once far away from
# mine eyes
from formatting import decrypt_this

# Initialise flask app!
app = Flask(__name__)

# Initialise Gzip
compress = Compress()

# Formerly /decrytpr
@app.route('/')
def decryptr():
    return render_template('decryptr.html', deciphered_text="",original_text="",checkbox_status="1")

@app.route('/endpoint',methods=['POST'])
def entry():
    return jsonify({'text': decrypt_this(request.form['text'],request.form['cipher'],request.form['type'],request.form['timeout'])})

def create_app():
    compress.init_app(app)
    app.run(threaded=True, ssl_context='adhoc')

# Run threaded in production!
if __name__ == '__main__':
    compress.init_app(app)
    app.run(host='0.0.0.0', threaded=True, ssl_context='adhoc')
