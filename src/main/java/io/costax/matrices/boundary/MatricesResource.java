package io.costax.matrices.boundary;

import io.costax.matrices.entity.Matrix;

import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;
import javax.ws.rs.GET;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.core.MediaType;
import java.util.List;
import java.util.logging.Logger;

@Path("/matrices")
@Produces(MediaType.APPLICATION_JSON)
public class MatricesResource {

    private static final Logger LOGGER = Logger.getLogger(MatricesResource.class.getName());

    @PersistenceContext
    EntityManager manager;


    @GET
    public List<Matrix> ping() {

        LOGGER.info("---- Get Matrix");

        return manager.createQuery("select m from Matrix m", Matrix.class).getResultList();
    }

}
