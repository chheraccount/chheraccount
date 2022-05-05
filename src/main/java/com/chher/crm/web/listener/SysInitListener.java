package com.chher.crm.web.listener;

import com.chher.crm.settings.domain.DicValue;
import com.chher.crm.settings.service.DicService;
import com.chher.crm.settings.service.impl.DicServiceImpl;
import com.chher.crm.utils.ServiceFactory;

import javax.servlet.ServletContext;
import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import java.util.*;

public class SysInitListener implements ServletContextListener {

    public void contextInitialized(ServletContextEvent sce) {

        System.out.println("创建数据字典");
        //创建上下文作用域对象
        ServletContext application = sce.getServletContext();

        DicService dicService = (DicService) ServiceFactory.getService(new DicServiceImpl());

        Map<String, List<DicValue>> map = dicService.getAll();

        Set<String> keys = map.keySet();


        for(String key:keys){

            application.setAttribute(key,map.get(key));
        }

        System.out.println("字典创建完成");

        //数据字典处理完毕后，处理Stage2Possibility.properties文件
        /*

            处理Stage2Possibility.properties文件步骤：
                解析该文件，将该属性文件中的键值对关系处理成为java中键值对关系（map）

                Map<String(阶段stage),String(可能性possibility)> pMap = ....
                pMap.put("01资质审查",10);
                pMap.put("02需求分析",25);
                pMap.put("07...",...);

                pMap保存值之后，放在服务器缓存中
                application.setAttribute("pMap",pMap);

         */

        //解析properties文件

        ResourceBundle resourceBundle = ResourceBundle.getBundle("Stage2Possibility");
        Map<String,String> pMap = new HashMap<String,String>();
        Enumeration<String> e = resourceBundle.getKeys();
        while (e.hasMoreElements()){

            //阶段
            String key = e.nextElement();
            //可能性
            String value = resourceBundle.getString(key);

            pMap.put(key, value);

        }

        //将pMap保存到服务器缓存中
        application.setAttribute("pMap", pMap);

    }

    public void contextDestroyed(ServletContextEvent sce) {


    }
}
