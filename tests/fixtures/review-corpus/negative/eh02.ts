async function handle(): Promise<void> {
  try {
    await run();
  } catch (error) {
    console.error(error);
  }
}
