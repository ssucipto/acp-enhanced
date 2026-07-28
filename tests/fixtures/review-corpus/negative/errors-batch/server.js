const app = express();
process.on("unhandledRejection", (err) => console.error(err));
app.listen(3000);
