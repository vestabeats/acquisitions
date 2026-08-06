import app from './app.js';

const PORT = process.env.port || 3000;

app.listen(PORT, () => {
  console.log(`app listening on http://localhost:${PORT}`);
});
