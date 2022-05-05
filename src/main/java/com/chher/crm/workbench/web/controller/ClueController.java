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
import com.chher.crm.workbench.domain.Clue;
import com.chher.crm.workbench.domain.Tran;
import com.chher.crm.workbench.service.ClueService;
import com.chher.crm.workbench.service.Impl.ClueServiceImpl;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class ClueController extends HttpServlet {

    @Override
    protected void service(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        System.out.println("进入线索控制层");

        String path = request.getServletPath();


        if ("/workbench/clue/getUserList.do".equals(path)) {
            getUserList(request, response);
        }else if ("/workbench/clue/saveClue.do".equals(path)) {
            saveClue(request, response);
        }else if("/workbench/clue/pageList.do".equals(path)){
            pageList(request,response);
        }else if("/workbench/clue/deleteClue.do".equals(path)){
            deleteClue(request,response);
        }else if("/workbench/clue/getUserListAndClue.do".equals(path)){
            getUserListAndClue(request,response);
        }else if("/workbench/clue/updateClue.do".equals(path)){
            updateClue(request,response);
        }else if("/workbench/clue/detail.do".equals(path)){
            detail(request,response);
        }else if("/workbench/clue/showActivity.do".equals(path)){
            showActivity(request,response);
        }else if("/workbench/clue/unbund.do".equals(path)){
            unbund(request,response);
        }else if("/workbench/clue/getNotBundActivityByName.do".equals(path)){
            getNotBundActivityByName(request,response);
        }else if("/workbench/clue/bund.do".equals(path)){
            bund(request,response);
        }else if("/workbench/clue/getActivityByName.do".equals(path)){
            getActivityByName(request,response);
        }else if("/workbench/clue/convert.do".equals(path)){
            convert(request,response);
        }
    }

    private void convert(HttpServletRequest request, HttpServletResponse response) throws IOException {
        System.out.println("线索转换");

        String clueId = request.getParameter("clueId");
        ClueService clueService = (ClueService) ServiceFactory.getService(new ClueServiceImpl());
        String flag = request.getParameter("flag");
        String createBy = ((User)request.getSession().getAttribute("user")).getName();

        Tran tran = null;
        //如果需要创建交易
        if("a".equals(flag)){

            tran = new Tran();

            //接受表中其它参数
            String money = request.getParameter("money");
            String name = request.getParameter("name");
            String expectedDate = request.getParameter("expectedDate");
            String stage = request.getParameter("stage");
            String activityId = request.getParameter("activityId");
            String id = UUIDUtil.getUUID();
            String createTime = DateTimeUtil.getSysTime();

            tran.setId(id);
            tran.setMoney(money);
            tran.setCreateBy(createBy);
            tran.setName(name);
            tran.setStage(stage);
            tran.setActivityId(activityId);
            tran.setExpectedDate(expectedDate);
            tran.setCreateTime(createTime);

        }

         /*

            为业务层传递的参数：

            1.必须传递的参数clueId，有了这个clueId之后我们才知道要转换哪条记录
            2.必须传递的参数t，因为在线索转换的过程中，有可能会临时创建一笔交易（业务层接收的t也有可能是个null）

         */
        boolean flag1 = clueService.convert(clueId,tran,createBy);

        if(flag1){

            response.sendRedirect(request.getContextPath()+"/workbench/clue/index.jsp");
        }

    }

    private void getActivityByName(HttpServletRequest request, HttpServletResponse response) {
        System.out.println("查询市场信息");

        ClueService clueService = (ClueService) ServiceFactory.getService(new ClueServiceImpl());

        String name = request.getParameter("name");
        List<Activity> activityList = clueService.getActivityByName(name);

        PrintJson.printJsonObj(response,activityList);
    }

    private void bund(HttpServletRequest request, HttpServletResponse response) {
        System.out.println("将关联信息存入数据库");
        ClueService clueService = (ClueService) ServiceFactory.getService(new ClueServiceImpl());

        String clueId = request.getParameter("clueId");
        String [] ids = request.getParameterValues("activityId");
        boolean flag = clueService.bund(clueId,ids);
        PrintJson.printJsonFlag(response,flag);
    }

    private void getNotBundActivityByName(HttpServletRequest request, HttpServletResponse response) {

        System.out.println("查询未绑定的市场信息");

        ClueService clueService = (ClueService) ServiceFactory.getService(new ClueServiceImpl());

        String clueId = request.getParameter("clueId");
        String name = request.getParameter("name");
        List<Activity> activityList = clueService.getNotBundActivityByName(name,clueId);

        PrintJson.printJsonObj(response,activityList);
    }

    private void unbund(HttpServletRequest request, HttpServletResponse response) {

        System.out.println("解除绑定");

        ClueService clueService = (ClueService) ServiceFactory.getService(new ClueServiceImpl());

        String id = request.getParameter("id");

        boolean flag = clueService.unbund(id);

        PrintJson.printJsonFlag(response,flag);
    }

    private void showActivity(HttpServletRequest request, HttpServletResponse response) {

        System.out.println("通过clueId查询市场活动信息");

        ClueService clueService = (ClueService) ServiceFactory.getService(new ClueServiceImpl());

        String clueId = request.getParameter("clueId");

        List<Activity> aList= clueService.getActivityByClueId(clueId);

        PrintJson.printJsonObj(response,aList);
    }

    private void detail(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        System.out.println("进入clue备注页面");

        ClueService clueService = (ClueService) ServiceFactory.getService(new ClueServiceImpl());

        String id = request.getParameter("id");

        Clue clue = clueService.getClue(id);


        request.setAttribute("clue",clue);

        request.getRequestDispatcher("/workbench/clue/detail.jsp").forward(request,response);

    }

    private void updateClue(HttpServletRequest request, HttpServletResponse response) {

        System.out.println("更新clue");

        ClueService clueService = (ClueService) ServiceFactory.getService(new ClueServiceImpl());

        String id = request.getParameter("id");
        String fullname = request.getParameter("fullname");
        String appellation = request.getParameter("appellation");
        String owner = request.getParameter("owner");
        String company = request.getParameter("company");
        String job = request.getParameter("job");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String website = request.getParameter("website");
        String mphone = request.getParameter("mphone");
        String state = request.getParameter("state");
        String source = request.getParameter("source");
        String description = request.getParameter("description");
        String contactSummary = request.getParameter("contactSummary");
        String nextContactTime = request.getParameter("nextContactTime");
        String address = request.getParameter("address");
        String editTime = DateTimeUtil.getSysTime();
        String editBy = ((User)request.getSession().getAttribute("user")).getName();

        System.out.println(id);
        Clue c = new Clue();
        c.setAddress(address);
        c.setAppellation(appellation);
        c.setCompany(company);
        c.setContactSummary(contactSummary);
        c.setCreateBy(editBy);
        c.setEmail(email);
        c.setCreateTime(editTime);
        c.setId(id);
        c.setWebsite(website);
        c.setState(state);
        c.setSource(source);
        c.setPhone(phone);
        c.setOwner(owner);
        c.setNextContactTime(nextContactTime);
        c.setMphone(mphone);
        c.setJob(job);
        c.setFullname(fullname);
        c.setDescription(description);

        boolean flag = clueService.updateClue(c);
        PrintJson.printJsonFlag(response,flag);

    }

    private void getUserListAndClue(HttpServletRequest request, HttpServletResponse response) {

        ClueService clueService = (ClueService) ServiceFactory.getService(new ClueServiceImpl());

        String id = request.getParameter("id");

        System.out.println(id);

        Map<String,Object> map = clueService.getUserListAndClue(id);

        PrintJson.printJsonObj(response,map);
    }

    private void deleteClue(HttpServletRequest request, HttpServletResponse response) {

        System.out.println("进入到条件分页查询控制器");

        ClueService clueService = (ClueService) ServiceFactory.getService(new ClueServiceImpl());

        String [] ids = request.getParameterValues("id");

        boolean flag = clueService.deleteClue(ids);

        PrintJson.printJsonFlag(response,flag);

    }

    private void pageList(HttpServletRequest request, HttpServletResponse response) {

        System.out.println("进入到条件分页查询控制器");

        ClueService clueService = (ClueService) ServiceFactory.getService(new ClueServiceImpl());

        String fullname = request.getParameter("fullname");
        String company = request.getParameter("company");
        String mphone = request.getParameter("mphone");
        String owner = request.getParameter("owner");
        String phone = request.getParameter("phone");
        String state = request.getParameter("state");
        String source = request.getParameter("source");
        Integer pageNo = Integer.valueOf(request.getParameter("pageNo"));
        Integer pageSize = Integer.valueOf(request.getParameter("pageSize"));

        //跳过的行数
        Integer skipCount = (pageNo-1)*pageSize;

        Map<String, Object> map = new HashMap<String,Object>();
        map.put("fullname",fullname);
        map.put("company",company);
        map.put("mphone",mphone);
        map.put("owner",owner);
        map.put("phone",phone);
        map.put("state",state);
        map.put("source",source);
        map.put("skipCount",skipCount);
        map.put("pageSize",pageSize);

        PaginationVO<Clue> vo = clueService.pageList(map);

        PrintJson.printJsonObj(response,vo);
    }

    private void saveClue(HttpServletRequest request, HttpServletResponse response) {
        System.out.println("保存线索信息到数据库");

        ClueService clueService = (ClueService) ServiceFactory.getService(new ClueServiceImpl());

        String id = UUIDUtil.getUUID();
        String fullname = request.getParameter("fullname");
        String appellation = request.getParameter("appellation");
        String owner = request.getParameter("owner");
        String company = request.getParameter("company");
        String job = request.getParameter("job");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String website = request.getParameter("website");
        String mphone = request.getParameter("mphone");
        String state = request.getParameter("state");
        String source = request.getParameter("source");
        String description = request.getParameter("description");
        String contactSummary = request.getParameter("contactSummary");
        String nextContactTime = request.getParameter("nextContactTime");
        String address = request.getParameter("address");
        String createTime = DateTimeUtil.getSysTime();
        String createBy = ((User)request.getSession().getAttribute("user")).getName();

        Clue c = new Clue();
        c.setAddress(address);
        c.setAppellation(appellation);
        c.setCompany(company);
        c.setContactSummary(contactSummary);
        c.setCreateBy(createBy);
        c.setEmail(email);
        c.setCreateTime(createTime);
        c.setId(id);
        c.setWebsite(website);
        c.setState(state);
        c.setSource(source);
        c.setPhone(phone);
        c.setOwner(owner);
        c.setNextContactTime(nextContactTime);
        c.setMphone(mphone);
        c.setJob(job);
        c.setFullname(fullname);
        c.setDescription(description);

        boolean flag = clueService.saveClue(c);
        PrintJson.printJsonFlag(response,flag);
    }



    private void getUserList(HttpServletRequest request, HttpServletResponse response) {

        System.out.println("取得用户信息列表");
        UserService userService = (UserService) ServiceFactory.getService(new UserServiceImpl());
        List<User> userList = userService.getUserList();
        PrintJson.printJsonObj(response,userList);
    }
}

