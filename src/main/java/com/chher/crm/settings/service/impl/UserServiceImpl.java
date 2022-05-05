package com.chher.crm.settings.service.impl;

import com.chher.crm.settings.dao.UserDao;
import com.chher.crm.settings.domain.User;
import com.chher.crm.settings.service.UserService;
import com.chher.crm.utils.DateTimeUtil;
import com.chher.crm.utils.SqlSessionUtil;
import com.chher.crm.exception.LoginException;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class UserServiceImpl implements UserService {

    private UserDao userDao = SqlSessionUtil.getSqlSession().getMapper(UserDao.class);

    public User login(String loginAct, String loginPwd, String ip) throws LoginException {


        Map<String,String> map = new HashMap<String,String>();
        map.put("loginAct",loginAct);
        map.put("loginPwd",loginPwd);
        User user = userDao.login(map);

        System.out.println("下面进行登录验证");

        if(user==null){
            throw new LoginException("账户密码错误");
        }

        String expireTime= user.getExpireTime();
        String lockStake = user.getLockState();
        String allowIps = user.getAllowIps();
        String current_time = DateTimeUtil.getSysTime();


        if(expireTime.compareTo(current_time)<0){
            throw new LoginException("账户已失效");
        }

        if("0".equals(lockStake)){

            throw new LoginException("账户锁定中");
        }

        if(!(allowIps.contains(ip))){
            throw new LoginException("ip访问受限");
        }

        return user;
    }

    public List getUserList() {


        List<User> userList = userDao.getUserList();

        return userList;
    }

}
