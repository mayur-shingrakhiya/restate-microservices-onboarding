# Prisma Database Setup

Complete guide for setting up and managing the database with Prisma.

## Prerequisites

- PostgreSQL database running
- Database connection URL

## Initial Setup

### 1. Install Dependencies

```bash
npm install
```

This installs:

- `@prisma/client` - Prisma Client for database queries
- `prisma` - Prisma CLI for migrations and management

### 2. Configure Database

Create a `.env` file in the root directory:

```env
DATABASE_URL="postgresql://username:password@localhost:5432/onboarding_db"
```

**Example configurations:**

```env
# Local PostgreSQL
DATABASE_URL="postgresql://postgres:password@localhost:5432/onboarding_db"

# Docker PostgreSQL
DATABASE_URL="postgresql://postgres:password@host.docker.internal:5432/onboarding_db"

# Cloud Database (e.g., Supabase, Neon)
DATABASE_URL="postgresql://user:pass@db.example.com:5432/database?schema=public"
```

### 3. Generate Prisma Client

```bash
npx prisma generate
```

This creates the TypeScript types and Prisma Client based on your schema.

### 4. Push Schema to Database

```bash
npx prisma db push
```

This creates the tables in your database without creating migration files.

**OR** use migrations for production:

```bash
npx prisma migrate dev --name init
```

## Database Schema

```prisma
model User {
  id        String   @id @default(uuid())
  email     String   @unique
  name      String?
  status    String   @default("pending")
  kycStatus String   @default("not_started")
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt
}
```

## Prisma Commands

### Development

```bash
# Generate Prisma Client
npx prisma generate

# Push schema changes (no migrations)
npx prisma db push

# Create a migration
npx prisma migrate dev --name migration_name

# Open Prisma Studio (GUI)
npx prisma studio
```

### Production

```bash
# Run pending migrations
npx prisma migrate deploy

# Generate client for production
npx prisma generate
```

### Utilities

```bash
# Reset database (⚠️ Deletes all data)
npx prisma migrate reset

# View database structure
npx prisma db pull

# Format schema file
npx prisma format

# Validate schema
npx prisma validate
```

## Usage in Code

```typescript
import { PrismaClient } from "@prisma/client";

const prisma = new PrismaClient();

// Create user
const user = await prisma.user.create({
  data: {
    email: "user@example.com",
    name: "John Doe",
    status: "pending",
    kycStatus: "not_started",
  },
});

// Find user
const user = await prisma.user.findUnique({
  where: { email: "user@example.com" },
});

// Update user
const updated = await prisma.user.update({
  where: { id: "user-id" },
  data: { status: "active" },
});

// Delete user
await prisma.user.delete({
  where: { id: "user-id" },
});
```

## Prisma Studio

Interactive GUI for viewing and editing database data:

```bash
npx prisma studio
```

Opens at: http://localhost:5555

## Migrations

### Creating Migrations

```bash
# Create migration after schema changes
npx prisma migrate dev --name add_user_fields
```

### Migration Files

Located in `prisma/migrations/`:

```
prisma/migrations/
├── 20240101000000_init/
│   └── migration.sql
├── 20240102000000_add_user_fields/
│   └── migration.sql
└── migration_lock.toml
```

**Important:** Commit migration files to Git!

## Troubleshooting

### "Environment variable not found"

- Check `.env` file exists
- Verify `DATABASE_URL` is set correctly

### "Can't reach database server"

- Ensure PostgreSQL is running
- Check connection URL format
- Verify port and credentials

### "Column does not exist"

- Run `npx prisma generate`
- Run `npx prisma db push`
- Restart your dev server

### "Prisma Client needs to be regenerated"

- Run `npx prisma generate`
- Clear node_modules and reinstall if needed

## Best Practices

1. **Always commit migration files** - Others need them
2. **Use migrations in production** - Don't use `db push`
3. **Test migrations** - Before deploying
4. **Backup database** - Before major changes
5. **Use transactions** - For related operations

## Example: Transaction

```typescript
const result = await prisma.$transaction(async (tx) => {
  const user = await tx.user.create({
    data: { email: "user@example.com" },
  });

  // More operations...

  return user;
});
```

## Database Seeding

Create `prisma/seed.ts`:

```typescript
import { PrismaClient } from "@prisma/client";
const prisma = new PrismaClient();

async function main() {
  await prisma.user.create({
    data: {
      email: "admin@example.com",
      name: "Admin User",
      status: "active",
      kycStatus: "verified",
    },
  });
}

main()
  .catch(console.error)
  .finally(() => prisma.$disconnect());
```

Run seed:

```bash
npx prisma db seed
```

## References

- [Prisma Documentation](https://www.prisma.io/docs)
- [Prisma Schema Reference](https://www.prisma.io/docs/reference/api-reference/prisma-schema-reference)
- [Prisma Client API](https://www.prisma.io/docs/reference/api-reference/prisma-client-reference)
