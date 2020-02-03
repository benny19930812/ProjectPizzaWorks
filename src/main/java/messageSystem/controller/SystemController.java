package messageSystem.controller;


import java.util.ArrayList;
import java.util.Date;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

import messageSystem.websocket.MsgTemplate;
import messageSystem.websocket.WebSocketSessions;

@RestController
public class SystemController {

    @Autowired
    private MsgTemplate template;
    @Autowired
    public WebSocketSessions webSocketSession;
    
    @PostMapping("/broadcast")
    public OutputMessage broadcast(@RequestBody Message message) {
        OutputMessage outputMessage = new OutputMessage(new Date().toString(), message);
        template.broadcast(outputMessage);
        return outputMessage;
    }

    @PostMapping("/send/{user}")
    public OutputMessage broadcast(@PathVariable("user") String user, @RequestBody Message message) {
    	System.out.println(message.toString()+" to "+user);
        OutputMessage outputMessage = new OutputMessage(new Date().toString(), message);
        template.sendMsgToUser(user, outputMessage);
        return outputMessage;
    }
    
    @PostMapping("/messageSystem/allCoworker")
    public ArrayList<String> GetAllCoworker() {
    	return webSocketSession.getAllUsers();
    }
}
