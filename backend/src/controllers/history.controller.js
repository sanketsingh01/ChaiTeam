import { db } from '../libs/db.js';
import { ApiResponse } from '../utils/ApiResponse.js';
import { ApiError } from '../utils/ApiError.js';

export const getUserActivity = async (req, res) => {
  try {
    const { userId } = req.params;
    const { page = 1, limit = 20, activityType } = req.query;

    if (!userId) {
      throw new ApiError(400, 'User ID is required');
    }

    const skip = (page - 1) * limit;
    const take = parseInt(limit);

    const where = { userId };
    if (activityType) where.activityType = activityType;

    const [activities, total] = await Promise.all([
      db.userActivity.findMany({
        where,
        skip,
        take,
        orderBy: { createdAt: 'desc' },
        include: {
          user: {
            select: {
              id: true,
              name: true,
              email: true,
              image: true
            }
          }
        }
      }),
      db.userActivity.count({ where })
    ]);

    return res.status(200).json(
      new ApiResponse(
        200,
        { activities, total, page: parseInt(page), limit: parseInt(limit) },
        'User activities fetched successfully'
      )
    );
  } catch (error) {
    console.error('Error fetching user activities:', error);
    return res.status(error.statusCode || 500).json(
      new ApiError(error.statusCode || 500, error.message || 'Error fetching user activities')
    );
  }
};

export const getGroupActivity = async (req, res) => {
  try {
    const { groupId } = req.params;
    const { page = 1, limit = 20, activityType } = req.query;

    if (!groupId) {
      throw new ApiError(400, 'Group ID is required');
    }

    // Verify user is member of the group
    const groupMember = await db.groupMember.findFirst({
      where: {
        groupId,
        userId: req.user.id
      }
    });

    if (!groupMember && req.user.role !== 'ADMIN') {
      throw new ApiError(403, 'You are not a member of this group');
    }

    const skip = (page - 1) * limit;
    const take = parseInt(limit);

    const where = { groupId };
    if (activityType) where.activityType = activityType;

    const [activities, total] = await Promise.all([
      db.groupActivity.findMany({
        where,
        skip,
        take,
        orderBy: { createdAt: 'desc' },
        include: {
          user: {
            select: {
              id: true,
              name: true,
              email: true,
              image: true
            }
          },
          targetUser: {
            select: {
              id: true,
              name: true,
              email: true,
              image: true
            }
          },
          group: {
            select: {
              id: true,
              name: true
            }
          }
        }
      }),
      db.groupActivity.count({ where })
    ]);

    return res.status(200).json(
      new ApiResponse(
        200,
        { activities, total, page: parseInt(page), limit: parseInt(limit) },
        'Group activities fetched successfully'
      )
    );
  } catch (error) {
    console.error('Error fetching group activities:', error);
    return res.status(error.statusCode || 500).json(
      new ApiError(error.statusCode || 500, error.message || 'Error fetching group activities')
    );
  }
};

export const getBatchActivity = async (req, res) => {
  try {
    const { batchId } = req.params;
    const { page = 1, limit = 20, activityType } = req.query;

    if (!batchId) {
      throw new ApiError(400, 'Batch ID is required');
    }

    // Verify user is member of the batch or admin
    const batchMember = await db.batchMember.findFirst({
      where: {
        batchId,
        email: req.user.email
      }
    });

    if (!batchMember && req.user.role !== 'ADMIN') {
      throw new ApiError(403, 'You are not a member of this batch');
    }

    const skip = (page - 1) * limit;
    const take = parseInt(limit);

    const where = { batchId };
    if (activityType) where.activityType = activityType;

    const [activities, total] = await Promise.all([
      db.batchActivity.findMany({
        where,
        skip,
        take,
        orderBy: { createdAt: 'desc' },
        include: {
          user: {
            select: {
              id: true,
              name: true,
              email: true,
              image: true
            }
          },
          targetUser: {
            select: {
              id: true,
              name: true,
              email: true,
              image: true
            }
          },
          performer: {
            select: {
              id: true,
              name: true,
              email: true,
              image: true
            }
          },
          batch: {
            select: {
              id: true,
              name: true
            }
          }
        }
      }),
      db.batchActivity.count({ where })
    ]);

    return res.status(200).json(
      new ApiResponse(
        200,
        { activities, total, page: parseInt(page), limit: parseInt(limit) },
        'Batch activities fetched successfully'
      )
    );
  } catch (error) {
    console.error('Error fetching batch activities:', error);
    return res.status(error.statusCode || 500).json(
      new ApiError(error.statusCode || 500, error.message || 'Error fetching batch activities')
    );
  }
};

export const getSystemActivity = async (req, res) => {
  try {
    const { page = 1, limit = 20, activityType, severity } = req.query;

    // Only admins can view system activities
    if (req.user.role !== 'ADMIN') {
      throw new ApiError(403, 'Only administrators can view system activities');
    }

    const skip = (page - 1) * limit;
    const take = parseInt(limit);

    const where = {};
    if (activityType) where.activityType = activityType;
    if (severity) where.severity = severity;

    const [activities, total] = await Promise.all([
      db.systemActivity.findMany({
        where,
        skip,
        take,
        orderBy: { createdAt: 'desc' }
      }),
      db.systemActivity.count({ where })
    ]);

    return res.status(200).json(
      new ApiResponse(
        200,
        { activities, total, page: parseInt(page), limit: parseInt(limit) },
        'System activities fetched successfully'
      )
    );
  } catch (error) {
    console.error('Error fetching system activities:', error);
    return res.status(error.statusCode || 500).json(
      new ApiError(error.statusCode || 500, error.message || 'Error fetching system activities')
    );
  }
};
