import express from 'express';
import {
  getUserActivity,
  getGroupActivity,
  getBatchActivity,
  getSystemActivity
} from '../controllers/history.controller.js';
import { authMiddleWare } from '../middleware/auth.middleware.js';

const router = express.Router();

router.use(authMiddleWare);


router.get('/user/:userId', getUserActivity);


router.get('/group/:groupId', getGroupActivity);


router.get('/batch/:batchId', getBatchActivity);

// (admin only)
router.get('/system', getSystemActivity);

export default router;