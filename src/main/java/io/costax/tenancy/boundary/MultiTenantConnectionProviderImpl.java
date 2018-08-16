package io.costax.tenancy.boundary;

import org.hibernate.engine.config.spi.ConfigurationService;
import org.hibernate.engine.jdbc.connections.spi.AbstractMultiTenantConnectionProvider;
import org.hibernate.engine.jdbc.connections.spi.ConnectionProvider;
import org.hibernate.engine.jdbc.connections.spi.MultiTenantConnectionProvider;
import org.hibernate.service.UnknownUnwrapTypeException;
import org.hibernate.service.spi.ServiceRegistryAwareService;
import org.hibernate.service.spi.ServiceRegistryImplementor;

import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.logging.Logger;

public class MultiTenantConnectionProviderImpl implements MultiTenantConnectionProvider, ServiceRegistryAwareService {

    private static final Logger LOGGER = Logger.getLogger(MultiTenantConnectionProviderImpl.class.getName());
    private static final String DEFAULT_SCHEMA = "public";

    private DataSource dataSource;

    @Override
    public Connection getAnyConnection() throws SQLException {
        return getConnection(DEFAULT_SCHEMA);
    }

    @Override
    public void releaseAnyConnection(Connection connection) throws SQLException {
        LOGGER.info(() -> String.format("[Release connection] Setting schema to: [%s]", DEFAULT_SCHEMA));

        try {
            connection.setSchema(DEFAULT_SCHEMA);
        } finally {
            connection.close();
            LOGGER.info("[Release connection] Connection released.");
        }
    }

    @Override
    public Connection getConnection(String tenantIdentifier) throws SQLException {
        LOGGER.info(() -> String.format("[Get connection] Setting schema to: [%s] ", tenantIdentifier));

        if (tenantIdentifier == null || tenantIdentifier.isEmpty()) {
            throw new IllegalStateException("No tenant defined!");
        }

        Connection connection = dataSource.getConnection();
        connection.setSchema(tenantIdentifier);

        return connection;
    }

    @Override
    public void releaseConnection(String s, Connection connection) throws SQLException {
        releaseAnyConnection(connection);
    }

    @Override
    public boolean supportsAggressiveRelease() {
        return true;
    }

    @Override
    public void injectServices(ServiceRegistryImplementor serviceRegistry) {
        Object dataSourceConfigValue = serviceRegistry.getService(ConfigurationService.class).getSettings().get("hibernate.connection.datasource");

        if (DataSource.class.isInstance(dataSourceConfigValue)) {
            dataSource = (DataSource) dataSourceConfigValue;
        } else {
            throw new IllegalStateException("No data source defined.");
        }
    }

    @Override
    public boolean isUnwrappableAs(Class unwrapType) {
        return ConnectionProvider.class.equals(unwrapType) || MultiTenantConnectionProvider.class.equals(unwrapType) || AbstractMultiTenantConnectionProvider.class.isAssignableFrom(unwrapType);
    }

    @Override
    @SuppressWarnings("unchecked")
    public <T> T unwrap(Class<T> unwrapType) {
        if (this.isUnwrappableAs(unwrapType)) {
            return (T) this;
        } else {
            throw new UnknownUnwrapTypeException(unwrapType);
        }
    }
}
