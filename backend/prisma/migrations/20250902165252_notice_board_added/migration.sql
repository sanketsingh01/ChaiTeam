/*
  Warnings:

  - You are about to drop the `Batch` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the `BatchMember` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the `GroupMember` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the `Groups` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the `JoinApplication` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the `User` table. If the table is not empty, all the data it contains will be lost.

*/
-- CreateEnum
CREATE TYPE "public"."NoticeType" AS ENUM ('CHAT', 'NOTIFICATION', 'PINNED_CHAT', 'SYSTEM');

-- CreateEnum
CREATE TYPE "public"."NoticeStatus" AS ENUM ('ACTIVE', 'DELETED');

-- DropForeignKey
ALTER TABLE "public"."BatchMember" DROP CONSTRAINT "BatchMember_batchId_fkey";

-- DropForeignKey
ALTER TABLE "public"."GroupMember" DROP CONSTRAINT "GroupMember_groupId_fkey";

-- DropForeignKey
ALTER TABLE "public"."GroupMember" DROP CONSTRAINT "GroupMember_userId_fkey";

-- DropForeignKey
ALTER TABLE "public"."Groups" DROP CONSTRAINT "Groups_batchId_fkey";

-- DropForeignKey
ALTER TABLE "public"."Groups" DROP CONSTRAINT "Groups_leader_id_fkey";

-- DropForeignKey
ALTER TABLE "public"."JoinApplication" DROP CONSTRAINT "JoinApplication_groupId_fkey";

-- DropForeignKey
ALTER TABLE "public"."JoinApplication" DROP CONSTRAINT "JoinApplication_userId_fkey";

-- DropTable
DROP TABLE "public"."Batch";

-- DropTable
DROP TABLE "public"."BatchMember";

-- DropTable
DROP TABLE "public"."GroupMember";

-- DropTable
DROP TABLE "public"."Groups";

-- DropTable
DROP TABLE "public"."JoinApplication";

-- DropTable
DROP TABLE "public"."User";

-- CreateTable
CREATE TABLE "public"."users" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "role" "public"."userRole" NOT NULL DEFAULT 'USER',
    "createdAT" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAT" TIMESTAMP(3) NOT NULL,
    "accessToken" TEXT,
    "image" TEXT,
    "isVerified" BOOLEAN NOT NULL DEFAULT true,
    "refreshToken" TEXT,
    "provider" TEXT,
    "isInGroup" BOOLEAN NOT NULL DEFAULT false,

    CONSTRAINT "users_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."batches" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "createdAT" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAT" TIMESTAMP(3) NOT NULL,
    "status" "public"."status" NOT NULL DEFAULT 'ACTIVE',
    "description" TEXT,

    CONSTRAINT "batches_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."batch_members" (
    "id" TEXT NOT NULL,
    "batchId" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "createdAT" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "batch_members_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."groups" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "description" TEXT,
    "tags" JSONB,
    "leader_id" TEXT NOT NULL,
    "createdAT" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAT" TIMESTAMP(3) NOT NULL,
    "disbanded_at" TIMESTAMP(3),
    "disbanded_reason" TEXT,
    "visible_to_users" BOOLEAN NOT NULL DEFAULT true,
    "status" "public"."groupStatus" NOT NULL DEFAULT 'ACTIVE',
    "batchId" TEXT NOT NULL,
    "batchName" TEXT NOT NULL,
    "capacity" INTEGER NOT NULL,

    CONSTRAINT "groups_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."group_members" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "groupId" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "role" "public"."groupMemberRole" NOT NULL,

    CONSTRAINT "group_members_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."join_applications" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "groupId" TEXT NOT NULL,
    "reason" TEXT NOT NULL,
    "status" "public"."applicationStatus" NOT NULL DEFAULT 'PENDING',
    "createdAT" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAT" TIMESTAMP(3) NOT NULL,
    "email" TEXT NOT NULL,
    "name" TEXT NOT NULL,

    CONSTRAINT "join_applications_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."noticeboard" (
    "id" TEXT NOT NULL,
    "groupId" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "type" "public"."NoticeType" NOT NULL,
    "message" TEXT,
    "createdAT" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAT" TIMESTAMP(3) NOT NULL,
    "is_edited" BOOLEAN NOT NULL DEFAULT false,
    "status" "public"."NoticeStatus" NOT NULL DEFAULT 'ACTIVE',

    CONSTRAINT "noticeboard_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "users_email_key" ON "public"."users"("email");

-- CreateIndex
CREATE UNIQUE INDEX "batch_members_batchId_email_key" ON "public"."batch_members"("batchId", "email");

-- CreateIndex
CREATE UNIQUE INDEX "groups_leader_id_key" ON "public"."groups"("leader_id");

-- CreateIndex
CREATE UNIQUE INDEX "group_members_userId_key" ON "public"."group_members"("userId");

-- CreateIndex
CREATE UNIQUE INDEX "join_applications_userId_key" ON "public"."join_applications"("userId");

-- AddForeignKey
ALTER TABLE "public"."batch_members" ADD CONSTRAINT "batch_members_batchId_fkey" FOREIGN KEY ("batchId") REFERENCES "public"."batches"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."groups" ADD CONSTRAINT "groups_batchId_fkey" FOREIGN KEY ("batchId") REFERENCES "public"."batches"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."groups" ADD CONSTRAINT "groups_leader_id_fkey" FOREIGN KEY ("leader_id") REFERENCES "public"."users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."group_members" ADD CONSTRAINT "group_members_groupId_fkey" FOREIGN KEY ("groupId") REFERENCES "public"."groups"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."group_members" ADD CONSTRAINT "group_members_userId_fkey" FOREIGN KEY ("userId") REFERENCES "public"."users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."join_applications" ADD CONSTRAINT "join_applications_groupId_fkey" FOREIGN KEY ("groupId") REFERENCES "public"."groups"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."join_applications" ADD CONSTRAINT "join_applications_userId_fkey" FOREIGN KEY ("userId") REFERENCES "public"."users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."noticeboard" ADD CONSTRAINT "noticeboard_groupId_fkey" FOREIGN KEY ("groupId") REFERENCES "public"."groups"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."noticeboard" ADD CONSTRAINT "noticeboard_userId_fkey" FOREIGN KEY ("userId") REFERENCES "public"."users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
