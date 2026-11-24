- SQL Server stores data in **8 KB pages**. Every page a query touches in memory is one logical read. Fewer pages read means less work.
- **Physical reads** are pages fetched from disk because they weren't in memory yet. They depend on what happens to be cached, so they're noisy.
- **CPU time** is the processor work; **elapsed time** is what the user waits. Elapsed can be lower than CPU when a query runs in parallel.
- The **actual execution plan** shows what the engine really did. The estimated plan only shows what it planned to do.

```sql
CHECKPOINT;
DBCC DROPCLEANBUFFERS;
```
### How SQL Server uses memory
When you query a table, SQL Server reads its 8 KB pages from disk into the buffer pool (the RAM you capped at 8 GB). It then keeps those pages in memory, so running the same query again reads from RAM, which is much faster. That's why the second run of a query is usually faster than the first.

### What each command does
```sql
CHECKPOINT
```
Writes all dirty pages (pages changed in memory but not yet saved to disk) for the current database out to the data file. After this, those pages are "clean": the copy in memory matches the copy on disk.

```sql
DBCC DROPCLEANBUFFERS
```
Removes all clean pages from the buffer pool. It can't remove dirty pages, because their changes would be lost. That's why you run **CHECKPOINT** first: it turns dirty pages into clean ones so that everything gets cleared.

### Important cautions
- Never run this on a production server. It affects the whole instance, not just one database. Every user's queries suddenly have to read from disk, and performance drops until the cache refills. On your laptop it's fine.
- Compare logical reads, not just time. Logical reads stay the same whether the cache is cold or warm, so they're the fair before/after measure when you tune queries. Cold-cache timing is useful as an extra check, not the main metric.

