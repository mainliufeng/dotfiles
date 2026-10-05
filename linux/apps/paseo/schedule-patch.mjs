// Narrow workaround for Paseo 0.8.0's stale schedule snapshots. No agent routing changes.
export function patchScheduleSource(source) {
  if (source.includes('paseoScheduleSnapshotFix')) return source;
  const start = '    async runSchedule(schedule, now, options) {\n        const manual = options?.manual === true;';
  const replacement = `    async runSchedule(schedule, now, options) {
        // paseoScheduleSnapshotFix: an earlier tick may finish while this tick awaits another site.
        const manual = options?.manual === true;
        const current = await this.store.get(schedule.id);
        if (!current) return;
        if (this.runningScheduleIds.has(schedule.id)) {
            if (manual) throw new Error(\`Schedule \${schedule.id} is already running\`);
            return;
        }
        if (!manual && (current.status !== "active" || current.nextRunAt !== schedule.nextRunAt ||
            !current.nextRunAt || new Date(current.nextRunAt).getTime() > this.now().getTime())) return;
        schedule = current;`;
  const oldAfter = 'const after = new Date(schedule.nextRunAt ?? now.toISOString());';
  const newAfter = 'const after = new Date(completedRuns.find((run) => run.id === params.runId)?.scheduledFor ?? schedule.nextRunAt ?? now.toISOString());';
  for (const anchor of [start, oldAfter]) {
    if (source.split(anchor).length !== 2) throw new Error('Paseo scheduler changed; revalidate the snapshot patch before launching.');
  }
  return source.replace(start, replacement).replace(oldAfter, newAfter);
}
