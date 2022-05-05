package com.chher.crm.workbench.service;

import com.chher.crm.workbench.domain.ActivityRemark;
import com.chher.crm.vo.PaginationVO;
import com.chher.crm.workbench.domain.Activity;

import java.util.List;
import java.util.Map;


public interface ActivityService {

    List<ActivityRemark> getActivityRemark(String activityId);

    boolean saveActivityRemark(ActivityRemark activityRemark);

    boolean deleteActivityRemark(String id);

    boolean updateActivityRemark(ActivityRemark activityRemark);

    Boolean saveActivity(Activity activity);

    PaginationVO<Activity> pageList(Map<String, Object> map);

    boolean deleteActivity(String[] ids);

    Map getUserListAndActivity(String id);

    boolean updateActivity(Activity a);

    Activity detail(String id);
}
