package com.chher.crm.workbench.service.Impl;

import com.chher.crm.workbench.dao.*;
import com.chher.crm.workbench.domain.*;
import com.chher.crm.workbench.service.ClueService;
import com.chher.crm.settings.dao.UserDao;
import com.chher.crm.settings.domain.User;
import com.chher.crm.utils.DateTimeUtil;
import com.chher.crm.utils.SqlSessionUtil;
import com.chher.crm.utils.UUIDUtil;
import com.chher.crm.vo.PaginationVO;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class ClueServiceImpl implements ClueService {

    //用户
    private UserDao userDao = SqlSessionUtil.getSqlSession().getMapper(UserDao.class);

    //市场活动
    private ActivityDao activityDao = SqlSessionUtil.getSqlSession().getMapper(ActivityDao.class);

    //线索
    private ClueDao clueDao = SqlSessionUtil.getSqlSession().getMapper(ClueDao.class);
    private ClueRemarkDao clueRemarkDao = SqlSessionUtil.getSqlSession().getMapper(ClueRemarkDao.class);
    private ClueActivityRelationDao clueActivityRelationDao = SqlSessionUtil.getSqlSession().getMapper(ClueActivityRelationDao.class);

    //客户
    private CustomerDao customerDao = SqlSessionUtil.getSqlSession().getMapper(CustomerDao.class);
    private CustomerRemarkDao customerRemarkDao = SqlSessionUtil.getSqlSession().getMapper(CustomerRemarkDao.class);

    //联系人
    private ContactsDao contactsDao = SqlSessionUtil.getSqlSession().getMapper(ContactsDao.class);
    private ContactsRemarkDao contactsRemarkDao = SqlSessionUtil.getSqlSession().getMapper(ContactsRemarkDao.class);
    private ContactsActivityRelationDao contactsActivityRelationDao = SqlSessionUtil.getSqlSession().getMapper(ContactsActivityRelationDao.class);
    //交易
    private TranDao tranDao = SqlSessionUtil.getSqlSession().getMapper(TranDao.class);
    private TranHistoryDao tranHistoryDao = SqlSessionUtil.getSqlSession().getMapper(TranHistoryDao.class);

    public boolean saveClue(Clue c) {
        boolean flag = true;

        int count = clueDao.save(c);

        if(count != 1){

            flag = false;

        }
        return flag ;
    }

    public PaginationVO<Clue> pageList(Map<String, Object> map) {
        PaginationVO<Clue> vo = new PaginationVO<Clue>();

        //条件分页多表查询
        List<Clue> datalist = clueDao.pageList(map);

        //条件分页多表查询总数
        int total = clueDao.getTotalByCondition(map);

        vo.setTotal(total);
        vo.setDataList(datalist);

        return vo;
    }

    public boolean deleteClue(String[] ids) {

        boolean flag = true;

        //查询clueRemark的数量
        int cr_count1 = clueRemarkDao.getTotalByClueIds(ids);

        //删除clue
        int c_count = clueDao.deleteByIds(ids);

        //删除clueRemark
        int cr_count2 = clueRemarkDao.deleteByClueIds(ids);

        if(cr_count2 != cr_count1){
            flag = false;
        }

        if(c_count != ids.length){
            flag = false;
        }
        return flag;
    }

    public Map<String, Object> getUserListAndClue(String id) {

        Map<String, Object> map = new HashMap<String, Object>();

        List<User> uList = userDao.getUserList();
        Clue c = clueDao.getById(id);

        map.put("uList",uList);
        map.put("clue",c);

        return map;
    }

    public boolean updateClue(Clue c) {

        boolean flag = true;

        int count = clueDao.updateById(c);

        if(count != 1){
            flag = false;
        }
        return flag;
    }

    public Clue getClue(String id) {

        Clue c = clueDao.detailById(id);

        return c;
    }

    public List<Activity> getActivityByClueId(String clueId) {

        List<Activity> aList= activityDao.getActivityByClueId(clueId);

        return aList;
    }

    public boolean unbund(String id) {
        boolean flag = true;
        int count = clueActivityRelationDao.unbund(id);
        if(count != 1){
            flag = false;
        }

        return flag;
    }

    public List<Activity> getNotBundActivityByName(String name, String clueId) {

        List<Activity> activityList = activityDao.getNotBundActivityByName(name,clueId);

        return activityList;
    }

    public boolean bund(String clueId, String[] ids) {
        boolean flag = true;

        for(String activityId:ids) {
            String id = UUIDUtil.getUUID();
            int count = clueActivityRelationDao.bund(id, clueId, activityId);
            if(count != 1){
                flag = false;
            }
        }

        return flag;
    }

    public List<Activity> getActivityByName(String name) {

        List<Activity> activityList = activityDao.getActivityByName(name);

        return activityList;
    }

    public boolean convert(String clueId, Tran tran, String createBy) {

        boolean flag = true;

        String createTime = DateTimeUtil.getSysTime();

        //(1) 获取到线索id，通过线索id获取线索对象（线索对象当中封装了线索的信息）
        Clue clue = clueDao.getById(clueId);

        //(2) 通过线索对象提取客户信息，当该客户不存在的时候，新建客户（根据公司的名称精确匹配，判断该客户是否存在！）
        String company = clue.getCompany();
        Customer customer = customerDao.getByName(company);

        if(customer == null){

            //创建客户
            customer = new Customer();
            customer.setAddress(clue.getAddress());
            customer.setWebsite(clue.getWebsite());
            customer.setPhone(clue.getPhone());
            customer.setOwner(clue.getOwner());
            customer.setNextContactTime(clue.getNextContactTime());
            customer.setName(company);
            customer.setId(UUIDUtil.getUUID());
            customer.setDescription(clue.getDescription());
            customer.setCreateBy(createBy);
            customer.setCreateTime(createTime);
            customer.setContactSummary(clue.getContactSummary());

            int count1 = customerDao.save(customer);
            if(count1 != 1){
                flag = false;
            }
        }

        //(3) 通过线索对象提取联系人信息，保存联系人
        Contacts contacts = new Contacts();
        contacts.setId(UUIDUtil.getUUID());
        contacts.setSource(clue.getSource());
        contacts.setOwner(clue.getOwner());
        contacts.setNextContactTime(clue.getNextContactTime());
        contacts.setMphone(clue.getMphone());
        contacts.setJob(clue.getJob());
        contacts.setFullname(clue.getFullname());
        contacts.setEmail(clue.getEmail());
        contacts.setAppellation(clue.getAppellation());
        contacts.setCustomerId(customer.getId());
        contacts.setCreateBy(createBy);
        contacts.setCreateTime(createTime);
        contacts.setAddress(clue.getAddress());
        contacts.setNextContactTime(clue.getNextContactTime());
        contacts.setDescription(clue.getDescription());
        int count2 = contactsDao.save(contacts);
        if(count2 != 1){
            flag = false;
        }

        //(4) 线索备注转换到客户备注以及联系人备注 先查再转
        List<ClueRemark> clueRemarkList = clueRemarkDao.getByClueId(clueId);

        for(ClueRemark clueRemark:clueRemarkList){
            String noteContent = clueRemark.getNoteContent();

            CustomerRemark customerRemark = new CustomerRemark();
            customerRemark.setCustomerId(customer.getId());
            customerRemark.setNoteContent(noteContent);
            customerRemark.setEditFlag("0");
            customerRemark.setCreateTime(createTime);
            customerRemark.setCreateBy(createBy);
            customerRemark.setId(UUIDUtil.getUUID());
            int count3 = customerRemarkDao.save(customerRemark);
            if(count3 != 1){
                flag = false;
            }

            ContactsRemark contactsRemark = new ContactsRemark();
            contactsRemark.setContactsId(contacts.getId());
            contactsRemark.setCreateBy(createBy);
            contactsRemark.setCreateTime(createTime);
            contactsRemark.setNoteContent(noteContent);
            contactsRemark.setEditFlag("0");
            contactsRemark.setId(UUIDUtil.getUUID());
            int count4 = contactsRemarkDao.save(contactsRemark);
            if(count4 != 1){
                flag = false;
            }
        }

        //(5) “线索和市场活动”的关系转换到“联系人和市场活动”的关系 先查再转
        List<ClueActivityRelation> clueActivityRelationList = clueActivityRelationDao.getByClueId(clueId);
        for(ClueActivityRelation clueActivityRelation:clueActivityRelationList){
            ContactsActivityRelation contactsActivityRelation = new ContactsActivityRelation();
            contactsActivityRelation.setActivityId(clueActivityRelation.getActivityId());
            contactsActivityRelation.setContactsId(contacts.getId());
            contactsActivityRelation.setId(UUIDUtil.getUUID());

            int count5 = contactsActivityRelationDao.save(contactsActivityRelation);
            if(count5 != 1){
                flag = false;
            }
        }

        //(6) 如果有创建交易需求，创建一条交易
        if(tran != null){
               /*

                t对象在controller里面已经封装好的信息如下：
                    id,money,name,expectedDate,stage,activityId,createBy,createTime

                接下来可以通过第一步生成的c对象，取出一些信息，继续完善对t对象的封装

             */

            tran.setContactsId(contacts.getId());
            tran.setCustomerId(customer.getId());
            tran.setSource(clue.getSource());
            tran.setContactSummary(clue.getContactSummary());
            tran.setDescription(clue.getDescription());
            tran.setNextContactTime(clue.getNextContactTime());
            tran.setOwner(clue.getOwner());

            //添加交易
            int count6 = tranDao.save(tran);
            if(count6!=1) {
                flag = false;
            }


            //(7) 如果创建了交易，则创建一条该交易下的交易历史
            TranHistory tranHistory = new TranHistory();
            tranHistory.setId(UUIDUtil.getUUID());
            tranHistory.setCreateBy(createBy);
            tranHistory.setCreateTime(createTime);
            tranHistory.setExpectedDate(tran.getExpectedDate());
            tranHistory.setMoney(tran.getMoney());
            tranHistory.setStage(tran.getStage());
            tranHistory.setTranId(tran.getId());
            //添加交易历史
            int count7 = tranHistoryDao.save(tranHistory);
            if(count7!=1){
                flag = false;
            }
        }
/*
        //(8) 删除线索备注
        int count8 = clueRemarkDao.deleteByClueId(clueId);
        if(count8 != clueRemarkList.size()){
            flag = false;
        }

        //(9) 删除线索和市场活动的关系
        int count9 = clueActivityRelationDao.deleteByClueId(clueId);
        if(count9 != clueActivityRelationList.size()){
            flag = false;
        }

        //(10) 删除线索
        int count10 = clueDao.deleteById(clueId);
        if(count10 != 1){
            flag = false;
        }*/

        return flag;
    }

}
