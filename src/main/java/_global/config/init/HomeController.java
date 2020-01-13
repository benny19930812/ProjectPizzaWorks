package _global.config.init;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
public class HomeController {
	
	//index Page
	@RequestMapping("/")
	public String home(){
		return "index";
	}
	
	//404 Page
//	@RequestMapping("/*")
	public String pageNoFound(){
		return "/_global/PageNoFound";
	}
}
