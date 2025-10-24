import express from 'express';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const app = express();
const port = process.env.PORT || 3000;

// Serve static files from the Remix build output
app.use(express.static(path.join(__dirname, 'build/client')));

// All other requests go to index.html
app.get('*', (req, res) => {
  res.sendFile(path.join(__dirname, 'build/client/index.html'));
});

app.listen(port, () => {
  console.log(`Server is running on port ${port}`);
});
