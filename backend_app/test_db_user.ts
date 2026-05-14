import { db } from './src/db/connection';
import { users } from './src/models/user';
async function test() {
  const u = await db.query.users.findFirst();
  console.log(u?.id);
  process.exit(0);
}
test();
