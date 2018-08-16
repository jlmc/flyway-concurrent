package io.costax;

import io.costax.tenancy.boundary.ThreadLocalContextHolder;

import javax.ws.rs.container.ContainerRequestContext;
import javax.ws.rs.container.ContainerRequestFilter;
import javax.ws.rs.container.ContainerResponseContext;
import javax.ws.rs.container.ContainerResponseFilter;
import javax.ws.rs.ext.Provider;
import java.io.IOException;

@Provider
public class XTenantFilterResolver implements ContainerRequestFilter, ContainerResponseFilter {


    @Override
    public void filter(ContainerRequestContext requestContext) throws IOException {
        String xtenant = requestContext.getHeaderString("Xtenant");

        if (xtenant != null) {
            ThreadLocalContextHolder.put("Xtenant", xtenant);
        }
    }

    @Override
    public void filter(ContainerRequestContext requestContext, ContainerResponseContext responseContext) throws IOException {
        ThreadLocalContextHolder.cleanupThread();
    }
}
