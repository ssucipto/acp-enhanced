async function work(): Promise<void> {
  try {
    await run();
  } catch (error: unknown) {
    throw error;
  }
}
