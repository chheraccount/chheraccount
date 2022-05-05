package com.chher.crm.settings.web.controller;

import com.chher.crm.utils.MD5Util;
import com.chher.crm.utils.PrintJson;
import com.chher.crm.utils.ServiceFactory;
import com.chher.crm.exception.LoginException;
import com.chher.crm.settings.domain.User;
import com.chher.crm.settings.service.UserService;
import com.chher.crm.settings.service.impl.UserServiceImpl;

import javax.servlet.*;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

public class UserController extends HttpServlet {

    @Override
    protected void service(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {


        System.out.println("进入到用户控制层");
        String path = request.getServletPath();


        if("/settings/user/login.do".equals(path)){
            login(request,response);
        }

    }

    private void login(HttpServletRequest request, HttpServletResponse response) {


        System.out.println("进入到登录验证操作");
        String loginAct = request.getParameter("loginAct");

        String loginPwd = request.getParameter("loginPwd");

        //将明文密码转换为密文
        loginPwd = MD5Util.getMD5(loginPwd);
        System.out.println(loginPwd.equals("202cb962ac59075b964b07152d234b70"));

        //获取ip
        String ip = request.getRemoteAddr();
        System.out.println("===============iP:"+ip);

        //走代理
        UserService userService = (UserService) ServiceFactory.getService(new UserServiceImpl());

        User user = null;

        try {
            user = userService.login(loginAct,loginPwd,ip);
            request.getSession().setAttribute("user",user);
            PrintJson.printJsonFlag(response,true);

        } catch (LoginException e) {
            e.printStackTrace();

            //表示登录失败
            /*

                {"success":true,"msg":?}

             */
            String msg = e.getMessage();
            /*

                我们现在作为controller，需要为ajax请求提供多项信息

                可以有两种手段来处理：
                    （1）将多项信息打包成为map，将map解析为json串
                    （2）创建一个Vo
                            private boolean success;
                            private String msg;


                    如果对于展现的信息将来还会大量的使用，我们创建一个vo类，使用方便
                    如果对于展现的信息只有在这个需求中能够使用，我们使用map就可以了

             */
            Map<String,Object> map = new HashMap<String,Object>();
            map.put("success", false);
            map.put("msg", msg);
            PrintJson.printJsonObj(response, map);
        }



    }
}

