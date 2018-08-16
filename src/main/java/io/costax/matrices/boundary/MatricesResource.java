package io.costax.matrices.boundary;

import io.costax.matrices.entity.Matrix;

import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;
import javax.ws.rs.GET;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.core.MediaType;
import java.util.List;

@Path("/matrices")
@Produces(MediaType.APPLICATION_JSON)
public class MatricesResource {

    @PersistenceContext
    EntityManager manager;

    @GET
    public List<Matrix> ping() {
        return manager.createQuery("select m from Matrix m", Matrix.class).getResultList();
    }

}
