package com.chher.crm.workbench.dao;

import com.chher.crm.workbench.domain.ActivityRemark;

import java.util.List;

public interface ActivityRemarkDao {

    int getCountByActivityId(String[] ids);

    int deleteByActivityId(String[] ids);

    List<ActivityRemark> getActivityRemarkByActivityId(String activityId);

    int saveActivityRemark(ActivityRemark activityRemark);

    int deleteById(String id);

    int updateById(ActivityRemark activityRemark);
}
