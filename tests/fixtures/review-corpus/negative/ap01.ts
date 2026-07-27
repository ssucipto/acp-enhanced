function sendResult(res: { json: (value: unknown) => void }, data: string): void {
  res.json({ data });
}
