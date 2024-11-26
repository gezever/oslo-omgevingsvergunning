import { JDBC, isJvmCreated, addOption, setupClasspath } from 'nodejs-jdbc';

if (!isJvmCreated()) {
    addOption("-Xrs");
    setupClasspath(['./drivers/hsqldb.jar',
        './drivers/derby.jar',
        './drivers/derbyclient.jar',
        './drivers/derbytools.jar']);
}

const config = {
    url: 'jdbc:hsqldb:hsql://localhost/xdb',
    user : 'SA',
    password: '',
    minpoolsize: 2,
    maxpoolsize: 3
};

const db = new JDBC(config);

// Initialize the pool
await db.initialize();

// Acquire a connection from the pool
const connobj = await db.reserve();
const { conn } = connobj;

// Create a statement
const statement = await conn.createStatement();
const sql = 'select 1';

// Execute the query and get the ResultSet
const rs = await statement.executeQuery(sql);

// Release the connection from the pool
await db.release(connobj);