// thanks, gpt :D

const express = require('express');
const app = express();
const port = 3000;
const messageLengthLimit = 60;
const fs = require('fs/promises'); 

app.use(express.json());
app.use(express.urlencoded({ extended: true }));

const messagesFilePath = '/var/messages.json';

function escapeHtml(text) {
    return text.replace(/&/g, "&amp;")
                .replace(/</g, "&lt;")
                .replace(/>/g, "&gt;")
                .replace(/"/g, "&quot;")
                .replace(/'/g, "&#039;");
}

async function readMessages() {
    const data = await fs.readFile(messagesFilePath, 'utf8');
    return JSON.parse(data);
}

async function writeMessages(messages) {
    await fs.writeFile(messagesFilePath, JSON.stringify(messages));
}

app.post('/add', async (req, res) => {
    const message = req.body.msg;
    if (typeof message === 'string' && message.length <= messageLengthLimit) {
        try {
            const messages = await readMessages();
            messages.push(escapeHtml(message));
            await writeMessages(messages);
            res.redirect('/');
        } catch (err) {
            console.error('Error processing request:', err);
            res.status(500).send('Server error');
        }
    } else {
        res.status(400).send('Invalid message');
    }
});

app.get('*', async (req, res) => {
    try {
        let messages = await readMessages();
        messages = messages.reverse(); 
        const messagesHtml = messages.map(msg => `<li>${msg}</li>`).join('');
        const html = `<meta charset='utf8'>
<style>
ul {
    list-style-type: none;
    padding: 0;
}
form { font-size: 16px; } 
li { 
    padding: 10px;
    background: beige;
    border: 1px dashed black;
    margin-bottom: 10px;
    font-size: 16px;
}
input {
    width: 100%;
    max-width: 600px;
    padding: 10px;
    font-size: 16px;
}
</style>
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Vieraskirja</title>
<h1>Vieraskirja</h1>
<form action='/add' method='post'>
    Viesti:<br>
    <input type='text' name='msg' maxlength='${messageLengthLimit}' autofocus>
    <br><br>
    <input type='submit' value='Lisää vieraskirjaan'>
</form>
<hr>
<ul>` + messagesHtml + `</ul>`;

        res.send(html);
    } catch (err) {
        console.error('Error reading messages file:', err);
        res.status(500).send('Server error');
    }
});

app.listen(port, () => {
    console.log(`Server listening on port ${port}`);
});
