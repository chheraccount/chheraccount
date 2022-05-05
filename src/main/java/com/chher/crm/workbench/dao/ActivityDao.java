package com.chher.crm.workbench.dao;

import com.chher.crm.workbench.domain.Activity;
import org.apache.ibatis.annotations.Param;

import java.util.List;
import java.util.Map;


public interface ActivityDao {
    int save(Activity activity);

    List<Activity> searchActivityByCondition(Map<String, Object> map);

    int searchTotalByCondition(Map<String, Object> map);

    int deleteById(String[] ids);

    Activity getActivityById(String id);

    int updateById(Activity a);

    Activity detailById(String id);

    List<Activity> getActivityByClueId(String clueId);

    List<Activity> getNotBundActivityByName(@Param("name") String name,@Param("clueId") String clueId);

    List<Activity> getActivityByName(String name);
}

