try {
  work();
} catch (error: unknown) {
  console.error(error);
  throw error;
}
async function gather(): Promise<void> {
  try {
    await Promise.all(tasks);
  } catch (error: unknown) {
    report(error);
  }
}
try {
  work();
} finally {
  cleanup();
}
class AppFailure extends Error {
  constructor(message: string) {
    super(message);
    this.name = "AppFailure";
  }
}
const indexValue = 1;
