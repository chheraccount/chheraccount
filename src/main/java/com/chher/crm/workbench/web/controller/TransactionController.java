package com.chher.crm.workbench.web.controller;

import com.chher.crm.settings.domain.User;
import com.chher.crm.settings.service.UserService;
import com.chher.crm.settings.service.impl.UserServiceImpl;
import com.chher.crm.utils.DateTimeUtil;
import com.chher.crm.utils.PrintJson;
import com.chher.crm.utils.ServiceFactory;
import com.chher.crm.utils.UUIDUtil;
import com.chher.crm.vo.PaginationVO;
import com.chher.crm.workbench.domain.Tran;
import com.chher.crm.workbench.domain.TranHistory;
import com.chher.crm.workbench.service.Impl.TransactionServiceImpl;
import com.chher.crm.workbench.service.TransactionService;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;


public class TransactionController extends HttpServlet {

    @Override
    protected void service(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        System.out.println("进入交易控制层");
        String path = request.getServletPath();

        if ("/workbench/transaction/getUserList.do".equals(path)) {
            getUserList(request, response);
        }else if ("/workbench/transaction/getCustomerName.do".equals(path)) {
            getCustomerName(request, response);
        }else if("/workbench/transaction/create.do".equals(path)){
            create(request, response);
        }else if("/workbench/transaction/save.do".equals(path)){
            save(request,response);
        }else if("/workbench/transaction/pageList.do".equals(path)){
            pageList(request,response);
        }else if("/workbench/transaction/detail.do".equals(path)){
            detail(request,response);
        }else if("/workbench/transaction/getHistoryListByTranId.do".equals(path)){
            getHistoryListByTranId(request,response);
        }else if("/workbench/transaction/changeStage.do".equals(path)){
            changeStage(request,response);
        }else if("/workbench/transaction/getCharts.do".equals(path)){
            getCharts(request,response);
        }

    }

    private void getCharts(HttpServletRequest request, HttpServletResponse response) {

        System.out.println("取得交易阶段数量统计图表的数据");

        TransactionService ts = ( TransactionService) ServiceFactory.getService(new  TransactionServiceImpl());

        /*

            业务层为我们返回
                total
                dataList

                通过map打包以上两项进行返回


         */
        Map<String,Object> map = ts.getCharts();

        PrintJson.printJsonObj(response, map);

    }

    private void changeStage(HttpServletRequest request, HttpServletResponse response) {

        System.out.println("执行改变阶段的操作");

        String id = request.getParameter("id");
        String stage = request.getParameter("stage");
        String money = request.getParameter("money");
        String expectedDate = request.getParameter("expectedDate");
        String editTime = DateTimeUtil.getSysTime();
        String editBy = ((User)request.getSession().getAttribute("user")).getName();

        Tran t = new Tran();
        t.setId(id);
        t.setStage(stage);
        t.setMoney(money);
        t.setExpectedDate(expectedDate);
        t.setEditBy(editBy);
        t.setEditTime(editTime);

        TransactionService ts = ( TransactionService) ServiceFactory.getService(new  TransactionServiceImpl());

        boolean flag = ts.changeStage(t);

        Map<String,String> pMap = (Map<String,String>)this.getServletContext().getAttribute("pMap");
        t.setPossibility(pMap.get(stage));

        Map<String,Object> map = new HashMap<String,Object>();
        map.put("success", flag);
        map.put("tran", t);

        PrintJson.printJsonObj(response, map);


    }

    private void getHistoryListByTranId(HttpServletRequest request, HttpServletResponse response) {

        System.out.println("根据交易id取得相应的历史列表");

        String tranId = request.getParameter("tranId");

        TransactionService ts = ( TransactionService) ServiceFactory.getService(new  TransactionServiceImpl());

        List<TranHistory> thList= ts.getHistoryListByTranId(tranId);

        //阶段和可能性之间的对应关系
        Map<String,String> pMap = (Map<String,String>)this.getServletContext().getAttribute("pMap");

        //将交易历史列表遍历
        for(TranHistory th : thList){

            //根据每条交易历史，取出每一个阶段
            String stage = th.getStage();
            String possibility = pMap.get(stage);
            th.setPossibility(possibility);

        }


        PrintJson.printJsonObj(response, thList);


    }


    private void detail(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        System.out.println("进入tran详细页面");

        TransactionService transactionService = (TransactionService) ServiceFactory.getService(new TransactionServiceImpl());

        String id = request.getParameter("id");

        Tran tran = transactionService.getTran(id);

        request.setAttribute("tran",tran);

        request.getRequestDispatcher("/workbench/transaction/detail.jsp").forward(request,response);
    }

    private void pageList(HttpServletRequest request, HttpServletResponse response) {
        System.out.println("分页查询");
        TransactionService transactionService = (TransactionService) ServiceFactory.getService(new TransactionServiceImpl());
        String owner = request.getParameter("owner");
        String name = request.getParameter("name");
        String company = request.getParameter("company");
        String stage = request.getParameter("stage");
        String type = request.getParameter("type");
        String source  = request.getParameter("source");
        String contactsName = request.getParameter("contactsName");
        Integer pageNo = Integer.valueOf(request.getParameter("pageNo"));
        Integer pageSize = Integer.valueOf(request.getParameter("pageSize"));

        //跳过的行数
        Integer skipCount = (pageNo-1)*pageSize;

        Map<String, Object> map = new HashMap<String,Object>();
        map.put("fullname",name);
        map.put("company",company);
        map.put("stage",stage);
        map.put("owner",owner);
        map.put("phone",type);
        map.put("contactsName",contactsName);
        map.put("source",source);
        map.put("skipCount",skipCount);
        map.put("pageSize",pageSize);

        PaginationVO<Tran> vo = transactionService.pageList(map);

        PrintJson.printJsonObj(response,vo);
    }

    private void save(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        System.out.println("将交易信息保存到数据库");
        TransactionService transactionService = (TransactionService) ServiceFactory.getService(new TransactionServiceImpl());

        String id = UUIDUtil.getUUID();
        String owner = request.getParameter("owner");
        String money = request.getParameter("money");
        String name = request.getParameter("name");
        String expectedDate = request.getParameter("expectedDate");
        String company = request.getParameter("company");
        String stage = request.getParameter("stage");
        String type = request.getParameter("type");
        String source  = request.getParameter("source");
        String activityId = request.getParameter("activityId");
        String contactsId = request.getParameter("contactsId");
        String description = request.getParameter("description");
        String contactSummary  = request.getParameter("contactSummary");
        String nextContactTime = request.getParameter("nextContactTime");
        String createBy = ((User)request.getSession().getAttribute("user")).getName();
        String createTime = DateTimeUtil.getSysTime();

        Tran tran = new Tran();
        tran.setOwner(owner);
        tran.setDescription(description);
        tran.setContactSummary(contactSummary);
        tran.setContactsId(contactsId);
        tran.setCreateBy(createBy);
        tran.setType(type);
        tran.setSource(source);
        tran.setNextContactTime(nextContactTime);
        tran.setMoney(money);
        tran.setName(name);
        tran.setId(id);
        tran.setActivityId(activityId);
        tran.setCreateTime(createTime);
        tran.setExpectedDate(expectedDate);
        tran.setStage(stage);

        boolean flag = transactionService.save(tran,company);

        if(flag){
            request.getRequestDispatcher("/workbench/transaction/index.jsp").forward(request,response);
        }
    }

    private void create(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        UserService userService = (UserService) ServiceFactory.getService(new UserServiceImpl());

        List<User> userList = userService.getUserList();
        request.setAttribute("userList",userList);
        request.getRequestDispatcher("/workbench/transaction/save.jsp").forward(request,response);
    }

    private void getCustomerName(HttpServletRequest request, HttpServletResponse response) {
        System.out.println("取得客户名称");
        String name = request.getParameter("name");
        TransactionService transactionService = (TransactionService) ServiceFactory.getService(new TransactionServiceImpl());
        List<String> nameList = transactionService.getNameList(name);

        PrintJson.printJsonObj(response,nameList);
    }

    private void getUserList(HttpServletRequest request, HttpServletResponse response) {

        System.out.println("取得用户信息列表");
        UserService userService = (UserService) ServiceFactory.getService(new UserServiceImpl());

        List<User> userList = userService.getUserList();

        PrintJson.printJsonObj(response,userList);

    }
}

