import 'dotenv/config';
import app from './src/app.js';

app.listen(5000, () => {
    console.log("server is running");
});
