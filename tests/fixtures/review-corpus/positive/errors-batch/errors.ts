try {
  work();
} catch (error: unknown) {
  console.error(error);
}
function gather(): Promise<void> {
  Promise.all(tasks);
  return Promise.resolve();
}
try {
  work();
} finally {
  return;
}
class AppFailure extends Error {
  constructor(message: string) {
    super(message);
  }
}
const x = 1;
