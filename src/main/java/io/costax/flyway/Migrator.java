package io.costax.flyway;

import org.flywaydb.core.Flyway;

import javax.naming.InitialContext;
import javax.naming.NamingException;
import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.logging.Logger;

public class Migrator {

    public static final String ADMIN_DATASOURCE_JNDI = "java:jboss/datasources/demoDSAdmin";
    private static final String SUPER_ADMIN_SCHEMA_NAME = "RK_SUPER_ADMIN";
    //private static final Migrator INSTANCE = new Migrator();
    private static Logger LOGGER = Logger.getLogger(Migrator.class.getName());
    //private Lock lock = new ReentrantLock();

    private Migrator() {
    }

    //public static Migrator instance() {
    //    return INSTANCE;
    // }

    public static synchronized void migrate() {
        DataSource dataSource = getDataSource(ADMIN_DATASOURCE_JNDI);

        migrateSuperAdminSchema(dataSource);

        migrateTenantSchema("public", dataSource);

        try (Connection connection = dataSource.getConnection();
             Statement statement = connection.createStatement();
             ResultSet result = statement.executeQuery("SELECT tenant_identifier FROM \"" + SUPER_ADMIN_SCHEMA_NAME + "\".client")) {


            while (result.next()) {
                String tenantName = result.getString("tenant_identifier");
                migrateTenantSchema(tenantName, dataSource);
            }

        } catch (SQLException e) {
            LOGGER.severe(() -> "ERROR Migration clients: " + e.getMessage());
            throw new IllegalStateException(e);
        }
    }

    private static void migrateSuperAdminSchema(DataSource dataSource) {
        LOGGER.info(() -> "Migrating [" + SUPER_ADMIN_SCHEMA_NAME + "] schema...");

        final Flyway flyway = new Flyway();

        flyway.setDataSource(dataSource);
        flyway.setLocations("db.migration.super-admin");
        flyway.setBaselineOnMigrate(true);
        flyway.setSchemas(SUPER_ADMIN_SCHEMA_NAME);

        flyway.migrate();
    }

    private static void migrateTenantSchema(String schemaName, DataSource dataSource) {
        LOGGER.info(() -> "Migrating [" + schemaName + "] schema...");


        final Flyway flyway = new Flyway();

        flyway.setDataSource(dataSource);
        flyway.setLocations("db.migration.tenant");
        //flyway.setBaselineOnMigrate(true);
        flyway.setSchemas(schemaName);

        flyway.migrate();

    }

    private static DataSource getDataSource(String dataSourceJndi) {
        try {
            return InitialContext.doLookup(dataSourceJndi);
        } catch (NamingException e) {
            throw new IllegalStateException(e);
        }
    }
}
