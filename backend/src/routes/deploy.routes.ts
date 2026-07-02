import { Hono } from 'hono';
import { listRemoteContainers, inspectRemoteContainer, deleteRemoteContainer } from '../services/container.service';
import { deploymentDb, routesDb } from '../db/database';
import { requireAuth, type AuthEnv } from '../middleware/auth.middleware';

const deployRoutes = new Hono<AuthEnv>();

/**
 * List containers belonging to the authenticated user.
 * ?all=true includes stopped containers.
 */
deployRoutes.get('/containers', requireAuth, async (c) => {
    const { login } = c.get('user');
    const all = c.req.query('all') === 'true';

    const deployments = await deploymentDb.getByLogin(login);
    const userContainerIds = new Set(deployments.map((d) => d.containerId));

    const containers = await listRemoteContainers(all);
    const filtered = containers.filter((ct: any) => userContainerIds.has(ct.id));

    return c.json({ data: filtered, count: filtered.length });
});

/**
 * Inspect a single container (must belong to the authenticated user).
 */
deployRoutes.get('/containers/:id', requireAuth, async (c) => {
    const { login } = c.get('user');
    const containerId = c.req.param('id');

    const deployments = await deploymentDb.getByLogin(login);
    if (!deployments.some((d) => d.containerId === containerId)) {
        return c.json({ error: 'Container not found' }, 404);
    }

    const data = await inspectRemoteContainer(containerId);
    return c.json({ data });
});

/**
 * Delete a container (stop + force-remove). Must belong to the authenticated user.
 */
deployRoutes.delete('/containers/:id', requireAuth, async (c) => {
    const { login } = c.get('user');
    const containerId = c.req.param('id');

    const deployments = await deploymentDb.getByLogin(login);
    const deployment = deployments.find((d) => d.containerId === containerId);
    if (!deployment) {
        return c.json({ error: 'Container not found' }, 404);
    }

    await deleteRemoteContainer(containerId);
    await deploymentDb.delete(deployment.id);

    return c.json({ success: true });
});

/**
 * Get all Caddy routes (for debugging)
 */
deployRoutes.get('/routes', async (c) => {
    try {
        const routes = await routesDb.getAll();
        return c.json({
            routes,
            count: routes.length
        });
    } catch (error: any) {
        console.error('Error fetching routes:', error);
        return c.json({ 
            error: 'Failed to fetch routes',
            message: error.message 
        }, 500);
    }
});

export { deployRoutes };
