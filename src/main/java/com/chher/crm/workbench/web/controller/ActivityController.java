package com.chher.crm.workbench.web.controller;

import com.chher.crm.settings.domain.User;
import com.chher.crm.settings.service.UserService;
import com.chher.crm.settings.service.impl.UserServiceImpl;
import com.chher.crm.utils.DateTimeUtil;
import com.chher.crm.utils.PrintJson;
import com.chher.crm.utils.ServiceFactory;
import com.chher.crm.utils.UUIDUtil;
import com.chher.crm.vo.PaginationVO;
import com.chher.crm.workbench.domain.Activity;
import com.chher.crm.workbench.domain.ActivityRemark;
import com.chher.crm.workbench.service.ActivityService;
import com.chher.crm.workbench.service.Impl.ActivityServiceImpl;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class ActivityController extends HttpServlet {

    @Override
    protected void service(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        System.out.println("进入市场活动控制层");
        String path = request.getServletPath();


        if("/workbench/activity/getUserList.do".equals(path)){
            getUserList(request,response);
        }else if("/workbench/activity/saveActivity.do".equals(path)){
            saveActivity(request,response);
        }else if("/workbench/activity/pageList.do".equals(path)){
            pageList(request,response);
        }else if("/workbench/activity/deleteActivity.do".equals(path)){
            deleteActivity(request,response);
        }else if("/workbench/activity/getUserListAndActivity.do".equals(path)){
            getUserListAndActivity(request,response);
        }else if("/workbench/activity/updateActivity.do".equals(path)){
            updateActivity(request,response);
        }else if("/workbench/activity/detail.do".equals(path)){
            detail(request,response);
        }else if("/workbench/activity/getActivityRemark.do".equals(path)){
            getActivityRemark(request,response);
        }else if("/workbench/activity/saveActivityRemark.do".equals(path)){
            saveActivityRemark(request,response);
        }else if("/workbench/activity/deleteActivityRemark.do".equals(path)){
            deleteActivityRemark(request,response);
        }else if("/workbench/activity/updateActivityRemark.do".equals(path)){
            updateActivityRemark(request,response);
        }

    }

    private void updateActivityRemark(HttpServletRequest request, HttpServletResponse response) {
        System.out.println("修改备注");

        ActivityService activityRemarkService = (ActivityService) ServiceFactory.getService(new ActivityServiceImpl());

        String id = request.getParameter("id");
        String noteContent = request.getParameter("noteContent");
        String editTime = DateTimeUtil.getSysTime();
        String editBy = ((User)request.getSession().getAttribute("user")).getName();
        String editFlag = "1";

        ActivityRemark ar = new ActivityRemark();

        ar.setId(id);
        ar.setNoteContent(noteContent);
        ar.setEditFlag(editFlag);
        ar.setEditBy(editBy);
        ar.setEditTime(editTime);

        boolean flag = activityRemarkService.updateActivityRemark(ar);

        Map<String,Object> map = new HashMap<String,Object>();
        map.put("ar",ar);
        map.put("success",flag);

        PrintJson.printJsonObj(response,map);
    }

    private void deleteActivityRemark(HttpServletRequest request, HttpServletResponse response) {
        System.out.println("删除备注");

        ActivityService activityRemarkService = (ActivityService) ServiceFactory.getService(new ActivityServiceImpl());

        String id = request.getParameter("id");

        boolean flag = activityRemarkService.deleteActivityRemark(id);

        PrintJson.printJsonObj(response,flag);
    }

    private void saveActivityRemark(HttpServletRequest request, HttpServletResponse response) {
        System.out.println("将备注保存到数据库");

        ActivityService activityRemarkService = (ActivityService) ServiceFactory.getService(new ActivityServiceImpl());

        String id = UUIDUtil.getUUID();
        String noteContent = request.getParameter("noteContent");
        String activityId = request.getParameter("activityId");
        String createTime = DateTimeUtil.getSysTime();
        String createBy = ((User)request.getSession().getAttribute("user")).getName();
        //初始为0 未编辑状态
        String editFlag = "0";

        ActivityRemark activityRemark = new ActivityRemark();
        activityRemark.setId(id);
        activityRemark.setNoteContent(noteContent);
        activityRemark.setCreateTime(createTime);
        activityRemark.setCreateBy(createBy);
        activityRemark.setEditFlag(editFlag);
        activityRemark.setActivityId(activityId);

        boolean flag = activityRemarkService.saveActivityRemark(activityRemark);

        Map<String,Object> map = new HashMap<String,Object>();
        map.put("ar",activityRemark);
        map.put("success",flag);
        PrintJson.printJsonObj(response,map);

    }

    private void getActivityRemark(HttpServletRequest request, HttpServletResponse response) {

        System.out.println("进入到备注页面中备注控制器");

        String activityId = request.getParameter("activityId");

        ActivityService activityRemarkService = (ActivityService) ServiceFactory.getService(new ActivityServiceImpl());

        List<ActivityRemark> activityRemarkList = activityRemarkService.getActivityRemark(activityId);

        PrintJson.printJsonObj(response,activityRemarkList);
    }

    private void detail(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        System.out.println("进入到备注页面中市场活动控制器");

        String id = request.getParameter("id");

        ActivityService activityService = (ActivityService) ServiceFactory.getService(new ActivityServiceImpl());

        Activity activity = activityService.detail(id);

        //转发重定向
        request.setAttribute("activity",activity);

        request.getRequestDispatcher("/workbench/activity/detail.jsp").forward(request,response);

    }

    private void updateActivity(HttpServletRequest request, HttpServletResponse response) {

        System.out.println("进入到数据更新控制器");

        ActivityService activityService = (ActivityService) ServiceFactory.getService(new ActivityServiceImpl());

        String id = request.getParameter("id");
        String owner = request.getParameter("owner");
        String name = request.getParameter("name");
        String startDate = request.getParameter("startDate");
        String endDate = request.getParameter("endDate");
        String cost = request.getParameter("cost");
        String description = request.getParameter("description");
        String editTime = DateTimeUtil.getSysTime();
        String editBy = ((User)request.getSession().getAttribute("user")).getName();

        Activity a = new Activity();
        a.setId(id);
        a.setOwner(owner);
        a.setName(name);
        a.setStartDate(startDate);
        a.setEndDate(endDate);
        a.setCost(cost);
        a.setDescription(description);
        a.setEditTime(editTime);
        a.setEditBy(editBy);

        boolean flag = activityService.updateActivity(a);

        PrintJson.printJsonFlag(response,flag);
    }

    private void getUserListAndActivity(HttpServletRequest request, HttpServletResponse response) {
        System.out.println("查询市场活动原信息控制器");

        ActivityService activityService = (ActivityService) ServiceFactory.getService(new ActivityServiceImpl());

        String id = request.getParameter("id");

        Map<String,Object> map = activityService.getUserListAndActivity(id);

        PrintJson.printJsonObj(response,map);
    }

    private void deleteActivity(HttpServletRequest request, HttpServletResponse response) {

        System.out.println("删除市场活动数据控制器");

        //删除市场活动信息，也要删除市场活动相关的详细信息
        ActivityService activityService = (ActivityService) ServiceFactory.getService(new ActivityServiceImpl());

        String [] ids = request.getParameterValues("id");

        boolean flag = activityService.deleteActivity(ids);

        PrintJson.printJsonFlag(response,flag);

    }

    private void pageList(HttpServletRequest request, HttpServletResponse response) {

        System.out.println("进入到条件分页查询控制器");

        ActivityService activityService = (ActivityService) ServiceFactory.getService(new ActivityServiceImpl());

        String owner = request.getParameter("owner");
        String name = request.getParameter("name");
        String startDate = request.getParameter("startDate");
        String endDate = request.getParameter("endDate");
        Integer pageNO = Integer.valueOf(request.getParameter("pageNo"));
        Integer pageSize = Integer.valueOf(request.getParameter("pageSize"));
        //计算忽略的条数
        Integer skipCount = (pageNO-1)*pageSize;
        System.out.println(pageNO+pageSize);

        Map<String,Object> map = new HashMap<String, Object>();
        map.put("owner",owner);
        map.put("name",name);
        map.put("startDate",startDate);
        map.put("endDate",endDate);
        map.put("skipCount",skipCount);
        map.put("pageSize",pageSize);

        PaginationVO<Activity> vo = activityService.pageList(map);

        PrintJson.printJsonObj(response,vo);

    }

    private void saveActivity(HttpServletRequest request, HttpServletResponse response) {

        System.out.println("保存市场活动信息");

        ActivityService activityService = (ActivityService) ServiceFactory.getService(new ActivityServiceImpl());

        //取得post传递的参数
        //uuid得到id
        String id =  UUIDUtil.getUUID();
        String owner = request.getParameter("owner");
        String name = request.getParameter("name");
        String startDate = request.getParameter("startDate");
        String endDate = request.getParameter("endDate");
        String cost = request.getParameter("cost");
        String description = request.getParameter("description");
        System.out.println(name);
        //创建时间：当前系统时间
        String createTime = DateTimeUtil.getSysTime();
        //创建人：当前登录用户
        String createBy = ((User)request.getSession().getAttribute("user")).getName();

        Activity a = new Activity();
        a.setId(id);
        a.setOwner(owner);
        a.setName(name);
        a.setStartDate(startDate);
        a.setEndDate(endDate);
        a.setCost(cost);
        a.setDescription(description);
        a.setCreateBy(createBy);
        a.setCreateTime(createTime);


        Boolean flag = activityService.saveActivity(a);

        PrintJson.printJsonFlag(response,flag);
    }
    private void getUserList(HttpServletRequest request, HttpServletResponse response) {

        System.out.println("取得用户信息列表");
        UserService userService = (UserService) ServiceFactory.getService(new UserServiceImpl());

        List<User> userList = userService.getUserList();

        PrintJson.printJsonObj(response,userList);

    }
}

