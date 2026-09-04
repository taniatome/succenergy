/**
 * Builds the SET clause of a partial update.
 *
 * The one place a dynamic statement is assembled, so the rule that makes it
 * safe is stated once and enforced once: **column names come from a fixed map
 * and values are always `$n` placeholders.** A field the caller supplies that
 * is not a key of that map cannot reach the SQL, so a patch built from a
 * request body cannot name a column of its own.
 */
export interface BuiltPatch {
  /** `col_a = $1, col_b = $2`, ready to follow `set`. Empty when nothing set. */
  clause: string;

  /** The values, in placeholder order. */
  values: unknown[];

  /** The next free placeholder number, for the `where` that follows. */
  nextIndex: number;
}

/**
 * @param columns  Allow-list: field name to column name.
 * @param patch    The fields to write. `undefined` is "leave alone"; an
 *                 explicit `null` is "set to null" and is included.
 * @param startAt  First placeholder number, for a statement that already has
 *                 parameters ahead of the SET clause.
 */
export function buildPatch<Field extends string>(
  columns: Readonly<Record<Field, string>>,
  patch: Partial<Record<Field, unknown>>,
  startAt = 1,
): BuiltPatch {
  const assignments: string[] = [];
  const values: unknown[] = [];

  for (const field of Object.keys(columns) as Field[]) {
    const value = patch[field];
    if (value === undefined) {
      continue;
    }
    values.push(value);
    assignments.push(`${columns[field]} = $${String(startAt + values.length - 1)}`);
  }

  return {
    clause: assignments.join(', '),
    values,
    nextIndex: startAt + values.length,
  };
}
