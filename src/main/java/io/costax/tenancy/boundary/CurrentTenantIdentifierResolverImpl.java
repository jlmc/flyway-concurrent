package io.costax.tenancy.boundary;

import org.hibernate.context.spi.CurrentTenantIdentifierResolver;

import java.util.Optional;
import java.util.logging.Logger;

/**
 * Resolves the current tenant name. Hibernate uses this to get a tenant identifier to pass to the connection provider.
 */
public class CurrentTenantIdentifierResolverImpl implements CurrentTenantIdentifierResolver {

    private static final Logger LOGGER = Logger.getLogger(CurrentTenantIdentifierResolverImpl.class.getName());

    @Override
    @SuppressWarnings("unchecked")
    public String resolveCurrentTenantIdentifier() {
        String tenantIdentifier = Optional.ofNullable(ThreadLocalContextHolder.get("Xtenant"))
                .map(Object::toString)
                .map(String::trim)
                .orElse("public");

        LOGGER.info("Resolving current tenant identifier: [" + tenantIdentifier + "]");

        return tenantIdentifier;
    }

    @Override
    public boolean validateExistingCurrentSessions() {
        return true;
    }
}