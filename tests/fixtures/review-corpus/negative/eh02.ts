async function handle(): Promise<void> {
  try {
    await run();
  } catch (error: unknown) {
    report(error);
  }
}
