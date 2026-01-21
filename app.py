import os
import subprocess
from flask import Flask, request, redirect, session

app = Flask(__name__)
app.secret_key = os.urandom(24)

# Credenciais vindas dos GitHub Secrets
USER = os.getenv("LOGIN_SEC")
PASSWORD = os.getenv("SENHA_SEC")

def login_required(func):
    def wrapper(*args, **kwargs):
        if not session.get("logged"):
            return redirect("/login")
        return func(*args, **kwargs)
    wrapper.__name__ = func.__name__
    return wrapper

@app.route("/login", methods=["GET", "POST"])
def login():
    if request.method == "POST":
        user = request.form.get("user")
        password = request.form.get("password")

        if user == USER and password == PASSWORD:
            session["logged"] = True
            return redirect("/")
        return "<h3>Login inválido</h3><a href='/login'>Voltar</a>"

    return """
    <h2>Login</h2>
    <form method="post">
        Usuário: <input name="user"><br><br>
        Senha: <input type="password" name="password"><br><br>
        <button type="submit">Entrar</button>
    </form>
    """

@app.route("/logout")
def logout():
    session.clear()
    return redirect("/login")

@app.route("/")
@login_required
def home():
    return """
    <h1>Servidor Ubuntu via Browser</h1>
    <p>Status: ONLINE</p>
    <a href="/logout">Logout</a>

    <h3>Executar comando Linux</h3>
    <form method="post" action="/cmd">
        <input name="cmd" style="width:400px">
        <button type="submit">Executar</button>
    </form>
    """

@app.route("/cmd", methods=["POST"])
@login_required
def cmd():
    command = request.form.get("cmd")
    if not command:
        return "Nenhum comando enviado"

    result = subprocess.getoutput(command)
    return f"<pre>{result}</pre><br><a href='/'>Voltar</a>"

if __name__ == "__main__":
    if not USER or not PASSWORD:
        print("ERRO: LOGIN ou SENHA não definidos nos GitHub Secrets")
        exit(1)

    app.run(host="127.0.0.1", port=5000)
