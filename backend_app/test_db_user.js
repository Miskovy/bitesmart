const { db } = require('./src/db/connection.js');
const { users } = require('./src/models/user.js');
async function test() {
  const u = await db.query.users.findFirst();
  console.log(u.id);
  process.exit(0);
}
test();
