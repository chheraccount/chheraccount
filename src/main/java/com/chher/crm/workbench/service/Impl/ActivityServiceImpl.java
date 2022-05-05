package com.chher.crm.workbench.service.Impl;

import com.chher.crm.workbench.domain.ActivityRemark;
import com.chher.crm.workbench.service.ActivityService;
import com.chher.crm.settings.dao.UserDao;
import com.chher.crm.settings.domain.User;
import com.chher.crm.utils.SqlSessionUtil;
import com.chher.crm.vo.PaginationVO;
import com.chher.crm.workbench.dao.ActivityDao;
import com.chher.crm.workbench.dao.ActivityRemarkDao;
import com.chher.crm.workbench.domain.Activity;

import java.util.HashMap;
import java.util.List;
import java.util.Map;


public class ActivityServiceImpl implements ActivityService {

    private ActivityDao activityDao = SqlSessionUtil.getSqlSession().getMapper(ActivityDao.class);
    private ActivityRemarkDao activityRemarkDao = SqlSessionUtil.getSqlSession().getMapper((ActivityRemarkDao.class));
    private UserDao userDao = SqlSessionUtil.getSqlSession().getMapper(UserDao.class);

    public Boolean saveActivity(Activity activity) {

        boolean flag = true;
        int count = activityDao.save(activity);
        if(count==0){
            flag=false;
        }
        System.out.println(flag);
        return flag;
    }

    public PaginationVO<Activity> pageList(Map<String, Object> map) {

        //条件查询+多表查询 owner存放的uuid 需要找到表tbl_user中对应的信息
        List<Activity> dataList  = activityDao.searchActivityByCondition(map);

        //查询总记录数
        int total = activityDao.searchTotalByCondition(map);

        PaginationVO<Activity> vo = new PaginationVO<Activity>();
        vo.setDataList(dataList);
        vo.setTotal(total);

        return vo;
    }

    public boolean deleteActivity(String[] ids) {


        boolean flag = true;
        //查询出需要删除的备注数量
        int count = activityRemarkDao.getCountByActivityId(ids);
        int ad_count = activityDao.deleteById(ids);
        int ard_count = activityRemarkDao.deleteByActivityId(ids);

        //判断市场活动删除的条数与id数是否相同
        if(ad_count != ids.length){
            flag = false;
        }

        //
        if(ard_count != count){
            flag = false;
        }

        return flag;
    }

    public Map<String,Object> getUserListAndActivity(String id) {


        //查询用户信息
        List<User> uList = userDao.getUserList();
        //查询市场活动信息
        Activity activity = activityDao.getActivityById(id);
        Map<String,Object> map = new HashMap<String,Object>();
        map.put("uList",uList);
        map.put("activity",activity);

        return map;
    }

    public boolean updateActivity(Activity a) {

        boolean flag = true;
        int count = activityDao.updateById(a);
        if(count != 1){
            flag = false;
        }
        return flag;
    }

    public Activity detail(String id) {

        Activity activity = activityDao.detailById(id);

        return activity;
    }

    public List<ActivityRemark> getActivityRemark(String activityId) {

        List<ActivityRemark> activityRemarkList = activityRemarkDao.getActivityRemarkByActivityId(activityId);

        return activityRemarkList;
    }

    public boolean saveActivityRemark(ActivityRemark activityRemark) {
        boolean flag = true;
        int count = activityRemarkDao.saveActivityRemark(activityRemark);
        if(count != 1){
            flag = false;
        }
        return flag;
    }

    public boolean deleteActivityRemark(String id) {
        boolean flag = true;
        int count = activityRemarkDao.deleteById(id);
        if(count !=1 ){
            flag = false;
        }
        return flag;
    }

    public boolean updateActivityRemark(ActivityRemark activityRemark) {
        boolean flag = true;

        int count = activityRemarkDao.updateById(activityRemark);

        if (count != 1) {
            flag = false;
        }
        return flag;
    }
}
