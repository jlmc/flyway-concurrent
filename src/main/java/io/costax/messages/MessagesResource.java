package io.costax.messages;

import javax.ws.rs.GET;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.core.MediaType;
import java.util.Arrays;
import java.util.List;

@Path("/messages")
@Produces(MediaType.APPLICATION_JSON)
public class MessagesResource {

    @GET
    public List<String> messages() {
        return Arrays.asList("hello", "Dummy");
    }
}
